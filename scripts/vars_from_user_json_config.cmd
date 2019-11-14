@echo off

SetLocal EnableDelayedExpansion

set "P=.azure.subscription_id"
set "V=AZURE_SUBSCRIPTION_ID"
for /f "tokens=*" %%G in ('type %JSON_SETTINGS_FILE% ^| jq -r !P!') do (set "!V!=%%G")

set "P=.azure.tenant_id"
set "V=AZURE_TENANT_ID"
for /f "tokens=*" %%G in ('type %JSON_SETTINGS_FILE% ^| jq -r !P!') do (set "!V!=%%G")

set "P=.azure.service_principal.app_id"
set "V=AZURE_SP_APP_ID"
for /f "tokens=*" %%G in ('type %JSON_SETTINGS_FILE% ^| jq -r !P!') do (set "!V!=%%G")

set "P=.azure.service_principal.obj_id"
set "V=AZURE_SP_OBJ_ID"
for /f "tokens=*" %%G in ('type %JSON_SETTINGS_FILE% ^| jq -r !P!') do (set "!V!=%%G")

set "P=.azure.service_principal.secret"
set "V=AZURE_SP_SECRET"
for /f "tokens=*" %%G in ('type %JSON_SETTINGS_FILE% ^| jq -r !P!') do (set "!V!=%%G")

set "P=.azure.resource_groups.custom_resource"
set "V=AZURE_RG_PROVIDER"
for /f "tokens=*" %%G in ('type %JSON_SETTINGS_FILE% ^| jq -r !P!') do (set "!V!=%%G")

set "P=.azure.resource_groups.postgresql"
set "V=AZURE_RG_POSTGRESQL"
for /f "tokens=*" %%G in ('type %JSON_SETTINGS_FILE% ^| jq -r !P!') do (set "!V!=%%G")

set "P=.custom_rp.domain"
set "V=CUSTOM_RP_DOMAIN"
for /f "tokens=*" %%G in ('type %JSON_SETTINGS_FILE% ^| jq -r !P!') do (set "!V!=%%G")

set "P=.custom_rp.secret_code"
set "V=CUSTOM_RP_SECRET_CODE"
for /f "tokens=*" %%G in ('type %JSON_SETTINGS_FILE% ^| jq -r !P!') do (set "!V!=%%G")

set "P=.keyvault.name"
set "V=KEYVAULT_NAME"
for /f "tokens=*" %%G in ('type %JSON_SETTINGS_FILE% ^| jq -r !P!') do (set "!V!=%%G")

set "P=.postgresql.name"
set "V=POSTGRESQL_NAME"
for /f "tokens=*" %%G in ('type %JSON_SETTINGS_FILE% ^| jq -r !P!') do (set "!V!=%%G")

set "P=.postgresql.admin"
set "V=POSTGRESQL_ADMIN"
for /f "tokens=*" %%G in ('type %JSON_SETTINGS_FILE% ^| jq -r !P!') do (set "!V!=%%G")

set "P=.postgresql.password"
set "V=POSTGRESQL_PASSWORD"
for /f "tokens=*" %%G in ('type %JSON_SETTINGS_FILE% ^| jq -r !P!') do (set "!V!=%%G")

EndLocal ^
    && set "AZURE_SUBSCRIPTION_ID=%AZURE_SUBSCRIPTION_ID%" ^
    && set "AZURE_TENANT_ID=%AZURE_TENANT_ID%" ^
    && set "AZURE_SP_APP_ID=%AZURE_SP_APP_ID%" ^
    && set "AZURE_SP_OBJ_ID=%AZURE_SP_OBJ_ID%" ^
    && set "AZURE_SP_SECRET=%AZURE_SP_SECRET%" ^
    && set "AZURE_RG_PROVIDER=%AZURE_RG_PROVIDER%" ^
    && set "AZURE_RG_POSTGRESQL=%AZURE_RG_POSTGRESQL%" ^
    && set "CUSTOM_RP_DOMAIN=%CUSTOM_RP_DOMAIN%" ^
    && set "CUSTOM_RP_SECRET_CODE=%CUSTOM_RP_SECRET_CODE%" ^
    && set "KEYVAULT_NAME=%KEYVAULT_NAME%" ^
    && set "POSTGRESQL_NAME=%POSTGRESQL_NAME%" ^
    && set "POSTGRESQL_ADMIN=%POSTGRESQL_ADMIN%" ^
    && set "POSTGRESQL_PASSWORD=%POSTGRESQL_PASSWORD%"
