@echo off

call %~dp0vars_populate.cmd

set /P DB_NAME=Enter database name: 

call az.bat rest ^
    --method DELETE ^
    --output json ^
    --uri "https://management.azure.com/%REQUEST_PATH%/%DB_NAME%?api-version=%API_VERSION%"
