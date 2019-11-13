@echo off

call %~dp0vars.cmd

call az.bat rest ^
    --method DELETE ^
    --output json ^
    --uri "https://management.azure.com%P%?api-version=%API_VERSION%"
