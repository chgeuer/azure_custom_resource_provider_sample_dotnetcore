@echo off

call %~dp0vars.cmd

set res=%customResourceProviderName%/%customResourceType%/
set P=/subscriptions/%sub%/resourceGroups/%rg%/providers/Microsoft.CustomProviders/resourceProviders/%res%

call az.bat rest ^
    --method GET ^
    --output json ^
    --uri "https://management.azure.com%P%?api-version=%API_VERSION%"
