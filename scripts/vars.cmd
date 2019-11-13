@echo off

set sub=%AZURE_SUBSCRIPTION_ID%
set rg=t1
set prefix=chgp123
set dbname=db3
set cert=%~dp0..\debugCert\democert.p12:""
set server_config=%~dp0..\appsettings.json
set TEMPLATE_DIR=%~dp0..\templates
set deployment_template=%TEMPLATE_DIR%\provider.json
set API_VERSION=2018-09-01-preview
set SP_APP_ID=69d6a1f2-0f24-4875-a182-55cf9cddc92f
set POSTGRESQL_PASSWORD=SuperSecret123.-
set POSTGRESQLHOST=%prefix%

REM Get rid of Python's f*cking 
REM      The command failed with an unexpected error.
REM      Here is the traceback: unknown encoding: cp65001
chcp 65001 >nul 2>&1
set PYTHONIOENCODING=utf-8

set P=.letsEncryptDomain
set V=host
for /f "tokens=*" %%a in ('cat %server_config% ^| jq -r %P%') do set %V%=%%a

set P=.requiredCodeParameter
set V=code
for /f "tokens=*" %%a in ('cat %server_config% ^| jq -r %P%') do set %V%=%%a

set P=.variables.customRP.name
set V=customResourceProviderName
for /f "tokens=*" %%a in ('cat %deployment_template% ^| jq -r %P%') do set %V%=%%a

set P=.resources[0].properties.resourceTypes[0].name
set V=customResourceType
for /f "tokens=*" %%a in ('cat %deployment_template% ^| jq -r %P%') do set %V%=%%a

set customEndpoint=https://%host%/customresource
set res=%customResourceProviderName%/%customResourceType%/%dbname%
set P=/subscriptions/%sub%/resourceGroups/%rg%/providers/Microsoft.CustomProviders/resourceProviders/%res%
