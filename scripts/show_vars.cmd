@echo off

call %~dp0vars.cmd

echo ------------------------------
echo SubscriptionID: %sub%
echo ResourceGroup:  %rg%
echo Provider Name:  %customResourceProviderName%
echo Resource Type:  %customResourceType%
echo Database Name:  %dbname%
echo Code:           %code%
echo Debug Cert:     %cert%
echo ------------------------------
echo CustomEndpoint  %customEndpoint%
echo Resource        %res%
echo ResourceID      %P%
echo ------------------------------
