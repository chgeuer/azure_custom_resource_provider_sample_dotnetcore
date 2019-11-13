@echo off

call %~dp0vars.cmd

set deploymentName=registerCRP

call az group deployment create ^
    --name %deploymentName% ^
    --resource-group %rg% ^
    --template-file %TEMPLATE_DIR%\provider.json ^
    --parameters ^
        resourceProviderURL=%customEndpoint% ^
        databaseName=%dbname% ^
        authzCode=%code%
