@echo off
REM Copyright (c) Microsoft Corporation.
REM Licensed under the MIT License.

set V=POSTGRESPASS
for /f "tokens=*" %%a in ('powershell -command "Write-Host (Get-Content -First 1 -Path $env:USERPROFILE\.pgpass).Split(\":\")[4].Trim()"') do set %V%=%%a

echo %POSTGRESPASS%
