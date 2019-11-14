@echo off

call %~dp0vars_populate.cmd

set "DEPLOYMENT_NAME=deployKeyvaultAndDatabase"

call az group deployment create ^
    --name %DEPLOYMENT_NAME% ^
    --resource-group %AZURE_RG_POSTGRESQL% ^
    --template-file %TEMPLATE_DIR%\postgresql_and_keyvault.json ^
    --parameters ^
        servicePrincipalObjectId=%AZURE_SP_OBJ_ID% ^
        keyvaultName=%KEYVAULT_NAME% ^
        postgresqlName=%POSTGRESQL_NAME% ^
        postgresqlAdmin=%POSTGRESQL_ADMIN% ^
        postgresqlPassword=%POSTGRESQL_PASSWORD%
