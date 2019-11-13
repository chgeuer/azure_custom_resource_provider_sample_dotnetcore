#region using statements

using System;
using System.Collections.Generic;
using System.IO.Compression;
using System.Linq;
using System.Net.Http;
using System.Net.Mime;
using System.Security.Claims;
using System.Security.Cryptography.X509Certificates;
using System.Text.Json.Serialization;
using System.Threading.Tasks;

using Microsoft.AspNetCore.Authentication.Certificate;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.ResponseCompression;
using Microsoft.AspNetCore.Server.Kestrel.Core;
using Microsoft.AspNetCore.Server.Kestrel.Https;
using Microsoft.Azure.KeyVault;
using Microsoft.Azure.Services.AppAuthentication;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

using Certes;
using FluffySpoon.AspNet.LetsEncrypt;
using Newtonsoft.Json.Linq;
using Npgsql;

#endregion

namespace AzureCustomResourceProviderRESTAPI
{
    public class Program
    {
        public static void Main(string[] args) => CreateHostBuilder(args).Build().Run();

        public static IHostBuilder CreateHostBuilder(string[] args) =>
            Host.CreateDefaultBuilder(args)
                .ConfigureLogging(loggingBuilder => loggingBuilder.AddConsole(consoleLoggerOptions =>
                {
                    consoleLoggerOptions.IncludeScopes = true;
                }))
                .ConfigureWebHostDefaults(webBuilder =>
                {
                    webBuilder
                        .UseStartup<MyStartup>()
                        .ConfigureAppConfiguration((_webHostBuilderContext, configurationBuilder) =>
                        {
                            configurationBuilder.AddEnvironmentVariables();
                        })
                        .UseKestrel(kestrelServerOptions =>
                        {
                            kestrelServerOptions.ListenAnyIP(
                                port: 80,
                                configure: lo => {
                                    lo.Protocols = HttpProtocols.Http1;
                                }
                            );
                            kestrelServerOptions.ListenAnyIP(
                                port: 443,
                                configure: lo => {
                                    lo.Protocols = HttpProtocols.Http1; // HttpProtocols.Http1AndHttp2;
                                    lo.UseHttps(hcao =>
                                    {
                                        // hcao.ClientCertificateValidation = (_cert, _chain, _polErrs) => true;
                                        // hcao.AllowAnyClientCertificate();
                                        hcao.ClientCertificateMode = ClientCertificateMode.AllowCertificate;
                                        hcao.ServerCertificateSelector = (_connectionContext, _s) =>
                                        {
                                            return LetsEncryptRenewalService.Certificate;
                                        };
                                    });
                                }
                            );
                        });
                }
            );
    }

    public class MyKeyVaultSettings
    {
        public string AzureKeyVaultName { get; set; }
        public string AzureKeyVaultSecretName { get; set; }

        public async Task<string> GetPostgreSQLConnectionString()
        {
            // https://docs.microsoft.com/en-us/azure/key-vault/service-to-service-authentication#connection-string-support

            // Environment.SetEnvironmentVariable("AzureServicesAuthConnectionString", $"RunAs=App;AppId={appId};TenantId={tenantID};AppKey={appSecret}");
            var kv = new KeyVaultClient(
                new KeyVaultClient.AuthenticationCallback(
                    new AzureServiceTokenProvider().KeyVaultTokenCallback));

            // Environment.SetEnvironmentVariable("AzureKeyVaultName", "chgp123-kv");
            // Environment.SetEnvironmentVariable("AzureKeyVaultSecretName", "postgresdatabaseconnectionstring");
            // var x = "Server=chgp123-postgresql.postgres.database.azure.com;Port=5432;Username=chgp123@chgp123-postgresql;Password=....;SSLMode=Prefer;"
            var secret = await kv.GetSecretAsync(
                vaultBaseUrl: $"https://{this.AzureKeyVaultName}.vault.azure.net/",
                secretName: this.AzureKeyVaultSecretName);

            return secret.Value;
        }
    }

    public class MyStartup
    {
        public MyStartup(IConfiguration configuration) 
        {
            Configuration = configuration; 
        }

        public IConfiguration Configuration { get; }

        public void ConfigureServices(IServiceCollection services)
        {
            services.ConfigureLetsEncrypt(domainToUse: this.Configuration["letsEncryptDomain"]);
          
            services.EnforceARMCaller(this.Configuration);

            services.Configure<MyKeyVaultSettings>(this.Configuration);

            services.Configure<GzipCompressionProviderOptions>(options =>
            {
                options.Level = CompressionLevel.Optimal;
            });
            services.AddResponseCompression(options =>
            {
                options.EnableForHttps = true;
                options.Providers.Add<GzipCompressionProvider>();
            });

            services.AddAuthorization();
            services.AddControllers();
        }

        public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }
            app.UseResponseCompression();
            app.UseLetsEncrypt();
            app.UseRouting();
            app.UseAuthentication();
            app.UseAuthorization();
            app.UseEndpoints(endpoints => endpoints.MapControllers());
        }
    }

    [Authorize]
    [ApiController]
    [Route("[controller]")]
    [Produces(MediaTypeNames.Application.Json)]
    public class CustomResourceController : ControllerBase
    {
        private readonly IConfiguration _configuration;
        private readonly MyKeyVaultSettings _keyVaultSettings;
        private readonly ILogger<CustomResourceController> _logger;
        private readonly string _requiredCodeParameter;

        public CustomResourceController(
            IConfiguration configuration,
            IOptions<MyKeyVaultSettings> keyVaultSettings, 
            ILogger<CustomResourceController> logger)
        {
            _configuration = configuration;
            _requiredCodeParameter = configuration["requiredCodeParameter"];
            _keyVaultSettings = keyVaultSettings.Value;
            _logger = logger;
        }

        [HttpGet()]
        public ActionResult<string> Get()
        {
            return new ActionResult<string>($"Hello {HttpContext.User.Identity.Name}");
        }

        [HttpDelete("subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.CustomProviders/resourceProviders/{**path}")]
        public async Task<ActionResult<Response>> Delete(string subscriptionId, string resourceGroupName, string path,
            [FromQuery(Name = "code")] string code, [FromQuery(Name = "api-version")] string _apiVersion)
        {
            if (_requiredCodeParameter != code) 
            {
                return Unauthorized($"Supplied query parameter '?code={code}' not accepted."); // TODO currently leaking too much sensitive data
            }

            var databaseName = path.Split("/").Last();
            try
            {
                var postgresConnectionStringBase = await _keyVaultSettings.GetPostgreSQLConnectionString();
                string connectionString(string db) => $"{postgresConnectionStringBase};Database={db}".Replace(";;", ";");

                const string managementDatabaseName = "postgres";
                using var managementConn = new NpgsqlConnection(connectionString(db: managementDatabaseName));
                await managementConn.OpenAsync();

                var steps = new[]
                {
                    // src: http://www.postgresqltutorial.com/postgresql-drop-database/
                    (
                        $"SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = '{databaseName}'",
                        $"Dropped connections to database {databaseName}"
                    ),
                    (
                        $"DROP DATABASE {databaseName}",
                        $"Finished deleting database {databaseName}"
                    )
                };
                
                foreach ((var statement, var logMessage) in steps)
                {
                    using var dropConnectionsCommand = new NpgsqlCommand(statement, managementConn);
                    await dropConnectionsCommand.ExecuteNonQueryAsync();
                    _logger.LogInformation(logMessage);
                }
               
                return Ok(new Response
                {
                    Code = code,
                    Caller = HttpContext.User.Identity.Name,
                    ID = HttpContext.Request.Headers["x-ms-correlation-request-id"],
                    SubscriptionId = subscriptionId,
                    ResourceGroupName = resourceGroupName,
                    Path = path
                });
            }
            catch (PostgresException pe) when (pe.SqlState == "3D000")
            {
                _logger.LogInformation($"Database {databaseName} didn't exist, but received a delete request");
                return Ok(); // should this return a 204?
            }
            catch (Exception e)
            {
                return BadRequest(e.Message);
            }
        }

        [HttpPut("subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.CustomProviders/resourceProviders/{**path}")]
        [Consumes(MediaTypeNames.Application.Json)]
        public async Task<ActionResult<Response>> Put(string subscriptionId, string resourceGroupName, string path, 
            [FromQuery(Name ="code")] string code, [FromQuery(Name="api-version")] string apiVersion, ARMRequest body)
        {
            if (_requiredCodeParameter != code)
            {
                return Unauthorized($"Supplied query parameter '?code={code}' not accepted."); // TODO currently leaking too much sensitive data
            }

            var databaseName = body.Properties.Database;
            try
            {
                var postgresConnectionStringBase = await _keyVaultSettings.GetPostgreSQLConnectionString();
                string connectionString(string db) => $"{postgresConnectionStringBase};Database={db}".Replace(";;", ";");

                const string managementDatabaseName = "postgres";
                using var managementConn = new NpgsqlConnection(connectionString(db: managementDatabaseName));
                await managementConn.OpenAsync();
                using var createDbCommand = new NpgsqlCommand($"CREATE DATABASE {databaseName}", managementConn);
                await createDbCommand.ExecuteNonQueryAsync();
                _logger.LogInformation($"Finished creating database {databaseName}");

                using var conn = new NpgsqlConnection(connectionString(db: databaseName));
                await conn.OpenAsync();
                using var createTableCommand = new NpgsqlCommand("CREATE TABLE tenants(tenant_id serial PRIMARY KEY, tenant_name VARCHAR(50) UNIQUE NOT NULL, subscription_id VARCHAR(50) NOT NULL)", conn);
                await createTableCommand.ExecuteNonQueryAsync();
                _logger.LogInformation($"Finished creating table {databaseName}/tenants");

                return Ok(new Response
                {
                    Code = code,
                    Caller = HttpContext.User.Identity.Name,
                    ID = HttpContext.Request.Headers["x-ms-correlation-request-id"],
                    SubscriptionId = subscriptionId,
                    ResourceGroupName = resourceGroupName,
                    Path = path,
                    Body = body
                });
            }
            catch (PostgresException pe) when (pe.SqlState == "42P04") 
            {
                _logger.LogInformation($"Database {databaseName} existed already");
                return Ok(); 
            }
            catch (Exception e)
            {
                return BadRequest(e.Message);
            }
        }
    }

    public class Response
    {
        public string Caller { get; set; }
        public string ID { get; set; }
        public string SubscriptionId { get; set; }
        public string ResourceGroupName { get; set; }
        public string Path { get; set; }
        public ARMRequest Body { get; set; }
        public string Code { get; internal set; }
    }

    public class DBDetails
    {
        [JsonPropertyName("database")]
        public string Database { get; set; }
    }

    public class ARMRequest
    {
        [JsonPropertyName("location")]
        public string Location { get; set; }

        [JsonPropertyName("properties")]
        public DBDetails Properties { get; set; }
    }
}

public static class MyExtensions
{
    public static void ConfigureLetsEncrypt(this IServiceCollection services, string domainToUse)
    {
        services.AddFluffySpoonLetsEncryptRenewalService(new LetsEncryptOptions
        {
            Email = "christian.geuer-pollmann@web.de",
            UseStaging = true,
            Domains = new[] { domainToUse },
            TimeUntilExpiryBeforeRenewal = TimeSpan.FromDays(30),
            TimeAfterIssueDateBeforeRenewal = TimeSpan.FromDays(7),
            RenewalFailMode = RenewalFailMode.LogAndRetry,
            CertificateSigningRequest = new CsrInfo
            {
                Organization = "Christian Geuer-Pollmann",
                OrganizationUnit = "Private",
                State = "NRW",
                CountryName = "Germany",
                Locality = "DE"
            }
        });
        services.AddFluffySpoonLetsEncryptFileChallengePersistence();
        services.AddFluffySpoonLetsEncryptFileCertificatePersistence();
    }

    public static void UseLetsEncrypt(this IApplicationBuilder app)
    {
        app.UseFluffySpoonLetsEncryptChallengeApprovalMiddleware();

        //const string LetsEncryptChallengePath = "/.well-known/acme-challenge";
        //app.MapWhen(
        //    httpContext => !httpContext.Request.Path.StartsWithSegments(LetsEncryptChallengePath),
        //    appBuilder => { appBuilder.UseHttpsRedirection(); }
        //);
        //app.MapWhen(
        //    httpContext => httpContext.Request.Path.StartsWithSegments(LetsEncryptChallengePath),
        //    appBuilder => { appBuilder.UseFluffySpoonLetsEncryptChallengeApprovalMiddleware(); }
        //);
    }

    internal class AuthorizedCallers
    {
        //
        // Allow the certificates listed in the JSON manifest (for production), 
        // as well as a list of named thumbprints (for development)
        // 
        private AuthorizedCallers() { }

        public string ArmURI { get; set; }

        public string[] ThumbPrints { get; set; }

        // `appsettings.json`:
        //
        // "authorizedCallers": { 
        //    "armURI": "https://customproviders.management.azure.com:24652/metadata/authentication",
        //    "thumbPrints": [ "2227B8175402AAF5BD4B5B80D51AB085EF61E7E8" ] 
        // },

        public static Task<string[]> FetchThumbprints(IConfiguration configuration)
        {
            var t = new AuthorizedCallers();
            configuration.GetSection("authorizedCallers").Bind(t);
            return t.GetCerts();
        }

        private async Task<string[]> GetCerts()
        {
            var armThumbs = await GetARMCertThumbPrintsAsync(this.ArmURI);
            return armThumbs.Union(this.ThumbPrints).ToArray();
        }

        private static async Task<IEnumerable<string>> GetARMCertThumbPrintsAsync(string requestUri)
        {
            using var c = new HttpClient();
            var response = await c.GetAsync(requestUri);
            var jsonString = await response.Content.ReadAsStringAsync();
            var json = JObject.Parse(jsonString);
            return ((JArray)json["clientCertificates"])
                .Select(x => (string)x["certificate"])
                .Select(Convert.FromBase64String)
                .Select(x => new X509Certificate2(x))
                .Select(x => x.Thumbprint)
                .ToArray();
        }
    }

    public static void EnforceARMCaller(this IServiceCollection services, IConfiguration configuration)
    {
        var certificateThumbPrints = AuthorizedCallers.FetchThumbprints(configuration).Result;

        services
            .AddAuthentication(CertificateAuthenticationDefaults.AuthenticationScheme)
            .AddCertificate(certAuthOpts =>
            {
                certAuthOpts.ValidateCertificateUse = true;
                certAuthOpts.ValidateValidityPeriod = true;
                certAuthOpts.RevocationMode = X509RevocationMode.Online;
                certAuthOpts.AllowedCertificateTypes = CertificateTypes.All;
                certAuthOpts.Events = new CertificateAuthenticationEvents
                {
                    // OnAuthenticationFailed = async (certificateAuthenticationFailedContext) => { },
                    OnCertificateValidated = certificateValidatedContext =>
                    {
                        var found = certificateThumbPrints.Any(thumb => thumb == certificateValidatedContext.ClientCertificate.Thumbprint);
                        if (found)
                        {
                            certificateValidatedContext.Principal = new ClaimsPrincipal(new ClaimsIdentity(new[] {
                                new Claim(ClaimTypes.NameIdentifier, certificateValidatedContext.ClientCertificate.Subject, 
                                    ClaimValueTypes.String, certificateValidatedContext.Options.ClaimsIssuer),
                                new Claim(ClaimTypes.Name, certificateValidatedContext.ClientCertificate.Subject, 
                                    ClaimValueTypes.String, certificateValidatedContext.Options.ClaimsIssuer)
                            }, certificateValidatedContext.Scheme.Name));
                            certificateValidatedContext.Success();
                        }
                        else
                        {
                            certificateValidatedContext.Fail("invalid cert");
                        }
                        return Task.CompletedTask;
                    }
                };
            }
        );
    }
}
