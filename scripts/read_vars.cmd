@echo off

set "P=.azure.subscription_id"
set "V=AZURE_SUBSCRIPTION_ID"
for /f "tokens=*" %%G in ('type %JSON_SETTINGS_FILE% ^| jq -r !P!') do (set "!V!=%%G")

set "P=.azure.tenant_id"
set "V=AZURE_TENANT_ID"
for /f "tokens=*" %%G in ('type %JSON_SETTINGS_FILE% ^| jq -r !P!') do (set "!V!=%%G")

set "P=.azure.prefix"
set "V=AZURE_PREFIX"
for /f "tokens=*" %%G in ('type %JSON_SETTINGS_FILE% ^| jq -r !P!') do (set "!V!=%%G")

set "P=.azure.service_principal.app_id"
set "V=AZURE_SP_APP_ID"
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

set "P=.postgresql.password"
set "V=POSTGRESQL_PASSWORD"
for /f "tokens=*" %%G in ('type %JSON_SETTINGS_FILE% ^| jq -r !P!') do (set "!V!=%%G")
