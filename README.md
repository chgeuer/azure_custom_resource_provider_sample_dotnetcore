# Setup

## Required information before you start

Please have the following things ready:

- Your Azure Subscription ID
- Your Azure AD Tenant ID
- An existing service principal, i.e. the application ID of the service principal, and a password.
  This service principal will be used by the custom resource provider to read the PostgreSQL connection string from KeyVault.

## Collecting information

To setup the overall environment, run [`scripts/vars_set.cmd`](scripts/vars_set.cmd). This script will interactively
collect various configuration values, and store them in `./vars_user.json`.
Please note that `vars_user.json` contains confidential information, and *must not be checked in* to git.
All other scripts read their config primarily from that file.

If you plan to run run the .NET core code locally, please run
[`scripts/set_AzureServicesAuthConnectionString.cmd`](scripts/set_AzureServicesAuthConnectionString.cmd).

This script will set a couple of environment variables needed by the running service, namely
`AzureServicesAuthConnectionString`, `AzureKeyVaultName` and `AzureKeyVaultSecretName`.

!! Now restart your shell, to ensure to pickup the new values !!

## Deploy demo resources

This demo needs an Azure KeyVault and a PostgreSQL DB instance. The [`scripts/DEPLOY_DB_KEYVAULT.cmd`](./scripts/DEPLOY_DB_KEYVAULT.cmd) command deploys these resources using the [`templates/postgresql_and_keyvault.json`](templates/postgresql_and_keyvault.json) template.

## Register the custom resource provider

To register the custom resource provider in a resource group, run the [`scripts/DEPLOY_CRP.cmd`](scripts/DEPLOY_CRP.cmd).

Each custom resource provider needs a name and a type. Currently, I'm pulling these out of [`templates/provider.json`](templates/provider.json)
