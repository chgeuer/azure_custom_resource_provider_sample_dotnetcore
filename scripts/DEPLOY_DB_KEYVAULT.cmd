@echo off

call %~dp0vars.cmd

set deploymentName=deployKeyvaultAndDatabase

call az group deployment create ^
    --name %deploymentName% ^
    --resource-group %rg% ^
    --template-file %TEMPLATE_DIR%\postgresql_and_keyvault.json ^
    --parameters ^
        deploymentName=%prefix% ^
        servicePrincipalAppID=%SP_APP_ID% ^
        postgresqlAdmin=%prefix% ^
        postgresqlPassword=%POSTGRESQL_PASSWORD%
