@echo off

call %~dp0vars.cmd

call az.bat rest ^
    --method DELETE ^
    --output json ^
    --uri "https://management.azure.com%REQUEST_PATH%/%dbname%?api-version=%API_VERSION%"
