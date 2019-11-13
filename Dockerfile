FROM mcr.microsoft.com/dotnet/core/aspnet:3.0-buster-slim AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/core/sdk:3.0-buster AS build
WORKDIR /src
COPY ["AzureCustomResourceProviderRESTAPI.csproj", ""]
RUN dotnet restore "./AzureCustomResourceProviderRESTAPI.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "AzureCustomResourceProviderRESTAPI.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "AzureCustomResourceProviderRESTAPI.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
COPY FluffySpoonAspNetLetsEncryptCertificate_* /app/
COPY democert.cer /usr/local/share/ca-certificates/
ENTRYPOINT ["dotnet", "AzureCustomResourceProviderRESTAPI.dll"]
