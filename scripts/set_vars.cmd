@echo off

setlocal EnableDelayedExpansion
set "USER_SETTINGS=%~dp0..\vars_user.json"

IF EXIST %USER_SETTINGS% (
    set JSON_SETTINGS_FILE=%USER_SETTINGS%
    call %~dp0read_vars.cmd
)

echo ------ Azure Overview configuration --------
set /P AZURE_SUBSCRIPTION_ID=Enter Azure Subscription ID (%AZURE_SUBSCRIPTION_ID%): 
set /P AZURE_TENANT_ID=Enter Azure AD Tenant ID (%AZURE_TENANT_ID%): 
set /P AZURE_SP_APP_ID=Enter Azure service principal application ID (%AZURE_SP_APP_ID%): 
set /P AZURE_SP_SECRET=Enter Azure service principal secret (press RETURN to leave unchanged): 
echo ------ Azure Naming configuration --------
set /P AZURE_PREFIX=Enter prefix for naming PostgreSQL and KeyVault instances (%AZURE_PREFIX%): 
set /P AZURE_RG_PROVIDER=Enter resource group name for custom RP (%AZURE_RG_PROVIDER%): 
set /P AZURE_RG_POSTGRESQL=Enter resource group name for PostgreSQL and KeyVault (%AZURE_RG_POSTGRESQL%): 
set /P POSTGRESQL_PASSWORD="Enter PostgreSQL password (press RETURN to leave unchanged): "
echo ------ Azure Custom Resource Provider configuration --------
set /P CUSTOM_RP_DOMAIN="Enter custom resource provider domain name (%CUSTOM_RP_DOMAIN%): "
set /P CUSTOM_RP_SECRET_CODE="Enter custom resource provider secret code query parameter (%CUSTOM_RP_SECRET_CODE%): "

type %~dp0vars_template.json ^
    | jq ".azure.subscription_id=\"%AZURE_SUBSCRIPTION_ID%\"" ^
    | jq ".azure.tenant_id=\"%AZURE_TENANT_ID%\"" ^
    | jq ".azure.prefix=\"%AZURE_PREFIX%\"" ^
    | jq ".azure.service_principal.app_id=\"%AZURE_SP_APP_ID%\"" ^
    | jq ".azure.service_principal.secret=\"%AZURE_SP_SECRET%\"" ^
    | jq ".azure.resource_groups.custom_resource=\"%AZURE_RG_PROVIDER%\"" ^
    | jq ".azure.resource_groups.postgresql=\"%AZURE_RG_POSTGRESQL%\"" ^
    | jq ".custom_rp.domain=\"%CUSTOM_RP_DOMAIN%\"" ^
    | jq ".custom_rp.secret_code=\"%CUSTOM_RP_SECRET_CODE%\"" ^
    | jq ".postgresql.password=\"%POSTGRESQL_PASSWORD%\"" ^
    > %USER_SETTINGS%
