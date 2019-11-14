@echo off

call %~dp0vars.cmd

%USERPROFILE%\bin\curl.exe ^
   --verbose --include ^
   --cert-type P12 --cert %cert% ^
   --request PUT --http1.1 ^
   --url %CUSTOM_ENDPOINT%/%REQUEST_PATH%?code=%CUSTOM_RP_SECRET_CODE% ^
   --header "Content-Type: application/json" ^
   --data "{\"properties\":{\"database\":\"%dbname%\"}}"
