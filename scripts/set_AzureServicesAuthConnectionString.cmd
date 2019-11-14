@echo off

call %~dp0vars_populate.cmd

setx AzureServicesAuthConnectionString "RunAs=App;TenantId=%AZURE_TENANT_ID%;AppId=%AZURE_SP_APP_ID%;AppKey=%AZURE_SP_SECRET%" >nul 2>&1
echo AzureServicesAuthConnectionString environment variable set

setx AzureKeyVaultName "%KEYVAULT_NAME%" >nul 2>&1
echo AzureKeyVaultName environment variable set

setx AzureKeyVaultSecretName "postgresdatabaseconnectionstring" >nul 2>&1
echo AzureKeyVaultSecretName environment variable set
