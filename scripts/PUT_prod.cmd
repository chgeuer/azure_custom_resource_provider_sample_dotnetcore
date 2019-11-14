@echo off

call %~dp0vars_populate.cmd

set /P DB_NAME=Enter database name: 

set deploymentName=depl1

call az group deployment create ^
    --name %deploymentName% ^
    --resource-group %AZURE_RG_PROVIDER% ^
    --template-file %TEMPLATE_DIR%\customresource.json ^
    --parameters databaseName=%DB_NAME%
