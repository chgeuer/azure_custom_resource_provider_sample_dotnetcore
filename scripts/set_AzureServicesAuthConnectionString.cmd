@echo off

call %~dp0vars_populate.cmd

setx AzureServicesAuthConnectionString "RunAs=App;TenantId=%AZURE_TENANT_ID%;AppId=%AZURE_SP_APP_ID%;AppKey=%AZURE_SP_SECRET%"
setx AzureKeyVaultName %KEYVAULT_NAME%
setx AzureKeyVaultSecretName postgresdatabaseconnectionstring
