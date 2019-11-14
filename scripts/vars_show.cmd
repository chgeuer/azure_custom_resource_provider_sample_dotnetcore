@echo off

setlocal

call %~dp0vars_populate.cmd

echo ===============================================================
echo AZURE_SUBSCRIPTION_ID:   %AZURE_SUBSCRIPTION_ID%
echo AZURE_TENANT_ID:         %AZURE_TENANT_ID%
echo   AZURE_SP_APP_ID:       %AZURE_SP_APP_ID%
echo   AZURE_SP_OBJ_ID:       %AZURE_SP_OBJ_ID%
echo ---------------------------------------------------------------
echo AZURE_RG_POSTGRESQL:     %AZURE_RG_POSTGRESQL%
echo   KEYVAULT_NAME:         %KEYVAULT_NAME%
echo   POSTGRESQL_NAME:       %POSTGRESQL_NAME%
echo   POSTGRESQL_ADMIN:      %POSTGRESQL_ADMIN%
echo ---------------------------------------------------------------
echo AZURE_RG_PROVIDER:       %AZURE_RG_PROVIDER%
echo   Provider Name:         %customResourceProviderName%
echo   Resource Type:         %customResourceType%
echo   CUSTOM_ENDPOINT        %CUSTOM_ENDPOINT%
echo   CUSTOM_RP_DOMAIN       %CUSTOM_RP_DOMAIN%
echo   CUSTOM_RP_SECRET_CODE: %CUSTOM_RP_SECRET_CODE%
echo   Debug Cert File:       %LOCAL_DEBUG_CERTIFICATE_FILE%
echo   REQUEST_PATH           %REQUEST_PATH%
echo ===============================================================
