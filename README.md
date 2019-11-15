# An ASP.NET Core (3.0)-based sample implementation of a custom resource provider for Azure

This application implements a [Custom Resource provider for Microsoft Azure][crpOverview]. The code is a REST-endpoint (implemented in ASP.NET Core 3). With this CRP, you can create and delete PostgreSQL databases (`CREATE DATABASE foo`) within an existing 'Azure Database for PostgreSQL' instance.

By default, ARM templates allow you to create a database instance (a server), but you need imperative code to create databases within the instance. This code does the following:

1. An ARM template for provisioning a PostgreSQL instance (so you have some resource to play around with), and a KeyVault instance (for storing the connection string)
2. An ARM template for registering a custom resource provider REST endpoint. This creates a hidden resource in your resource group. Please note that during the registration phase, there is no interaction between the ARM backend and our REST service.
3. An ARM template for creating a custom resource (in our sample a PostgreSQL database and a demo table)
4. A .NET Core application exposing the custom RP implementation via REST. During deployment/creation of the custom resource in the previous step, the ARM backend from Azure calls via `PUT` into our REST endpoint, and instructs it to create the actual custom resource.

## Setup

### Required information before you start

Please have the following things ready:

- Your Azure Subscription ID
- Your Azure AD Tenant ID
- An existing service principal, i.e. the application ID of the service principal, and a password.
  This service principal will be used by the custom resource provider to read the PostgreSQL connection string from KeyVault.
- Some location where you can host your REST endpoint, such as an Azure web app, or some VM with a public IP address.

### Collecting information

To setup the overall environment, run [`scripts/vars_set.cmd`](scripts/vars_set.cmd). This script will interactively
collect various configuration values, and store them in `./vars_user.json`.
Please note that `vars_user.json` contains confidential information, and *must not be checked in* to git.
All other scripts read their config primarily from that file.

If you plan to run run the .NET core code locally, please run
[`scripts/set_AzureServicesAuthConnectionString.cmd`](scripts/set_AzureServicesAuthConnectionString.cmd).

This script will set a couple of environment variables needed by the running service, namely
`AzureServicesAuthConnectionString`, `AzureKeyVaultName` and `AzureKeyVaultSecretName`.

!! Now restart your shell, to ensure to pickup the new values !!

### Deploy demo resources

This demo needs an Azure KeyVault and a PostgreSQL DB instance. The [`scripts/DEPLOY_DB_KEYVAULT.cmd`](./scripts/DEPLOY_DB_KEYVAULT.cmd) command deploys these resources using the [`templates/postgresql_and_keyvault.json`](templates/postgresql_and_keyvault.json) template.

### Register the custom resource provider

To register the custom resource provider in a resource group, run the [`scripts/DEPLOY_CRP.cmd`](scripts/DEPLOY_CRP.cmd).

Each custom resource provider needs a name and a type. Currently, I'm pulling these out of [`templates/provider.json`](templates/provider.json)

## Development

### Connectivity - Running your CRP in the privacy of your own dorm room

*DNS*: When developing the CRP, I wanted to be able to locally (on my laptop) set a breakpoint in the codebase, so I created a .NET Core 3 console app, self-hosting the REST API via Kestrel. My DSL router at regularly registers itself at a dynamic DNS service, and I created a CNAME at my private domain to point to that dynamic DNS entry.

*TCP Forwarding*: On my DSL router, I configured port forwarding for ports 80/443 to my development machine, so that inbound Internet connections to my proper CNAME end up on my dev box.

### TLS and peer entity authentication

When you register your CRP with an `https://` URL, the ARM backend calls into your REST endpoint and authenticates itself using an X509 client certificate. ARM requires your TLS endpoint to serve out a proper (valid) certificate, so the application uses the fabulous LetsEncrypt CA to dynamically fetch a server cert. The ACME dance during certificate issuance is also the reason why we're exposing port TCP/80 for the initial phase. Actual CRP request require a TLS-connection.

[crpOverview]: https://docs.microsoft.com/en-us/azure/managed-applications/custom-providers-overview
