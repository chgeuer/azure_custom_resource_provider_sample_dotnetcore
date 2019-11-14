@echo off

call %~dp0vars_populate.cmd

set deploymentName=registerCRP

call az group deployment create ^
    --name %deploymentName% ^
    --resource-group %AZURE_RG_PROVIDER% ^
    --template-file %TEMPLATE_DIR%\provider.json ^
    --parameters ^
        resourceProviderURL=%CUSTOM_ENDPOINT% ^
        authzCode=%CUSTOM_RP_SECRET_CODE%
