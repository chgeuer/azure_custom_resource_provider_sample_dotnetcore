@echo off

setlocal EnableDelayedExpansion

set dbname=db3

set "JSON_SETTINGS_FILE=%~dp0..\vars_user.json"
call %~dp0read_vars.cmd


set cert=%~dp0..\debugCert\democert.p12:""
set server_config=%~dp0..\appsettings.json
set TEMPLATE_DIR=%~dp0..\templates
set deployment_template=%TEMPLATE_DIR%\provider.json
set API_VERSION=2018-09-01-preview

REM Get rid of Python's f*cking 
REM      The command failed with an unexpected error.
REM      Here is the traceback: unknown encoding: cp65001
chcp 65001 >nul 2>&1
set PYTHONIOENCODING=utf-8

set P=.variables.customRP.name
set V=customResourceProviderName
for /f "tokens=*" %%a in ('type %deployment_template% ^| jq -r %P%') do set %V%=%%a

set P=.resources[0].properties.resourceTypes[0].name
set V=customResourceType
for /f "tokens=*" %%a in ('type %deployment_template% ^| jq -r %P%') do set %V%=%%a

set CUSTOM_ENDPOINT=https://%CUSTOM_RP_DOMAIN%/customresource
set REQUEST_PATH=/subscriptions/%AZURE_SUBSCRIPTION_ID%/resourceGroups/%AZURE_RG_PROVIDER%/providers/Microsoft.CustomProviders/resourceProviders/%customResourceProviderName%/%customResourceType%/
