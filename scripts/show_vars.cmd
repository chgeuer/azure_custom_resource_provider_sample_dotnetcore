@echo off
setlocal EnableDelayedExpansion

call %~dp0vars.cmd

echo ------------------------------
echo SubscriptionID:  %AZURE_SUBSCRIPTION_ID%
echo ResourceGroup:   %AZURE_RG_PROVIDER%
echo Provider Name:   %customResourceProviderName%
echo Resource Type:   %customResourceType%
echo Database Name:   %dbname%
echo Code:            %CUSTOM_RP_SECRET_CODE%
echo Debug Cert File: %cert%
echo ------------------------------
echo CUSTOM_ENDPOINT  %CUSTOM_ENDPOINT%
echo CUSTOM_RP_DOMAIN %CUSTOM_RP_DOMAIN%
echo REQUEST_PATH     %REQUEST_PATH%
echo ------------------------------
