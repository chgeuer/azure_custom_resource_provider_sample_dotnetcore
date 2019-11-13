@echo off

call %~dp0vars.cmd

set deploymentName=depl1

call az group deployment create ^
    --name %deploymentName% ^
    --resource-group %rg% ^
    --template-file %TEMPLATE_DIR%\customresource.json ^
    --parameters databaseName=%dbname%
