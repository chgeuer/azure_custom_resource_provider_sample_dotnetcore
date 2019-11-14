@echo off

call %~dp0vars.cmd

call az.bat rest ^
    --method GET ^
    --output json ^
    --uri "https://management.azure.com%REQUEST_PATH%?api-version=%API_VERSION%"
