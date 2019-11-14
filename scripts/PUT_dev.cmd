@echo off

call %~dp0vars_populate.cmd

set /P DB_NAME=Enter database name: 

%USERPROFILE%\bin\curl.exe ^
   --verbose --include ^
   --cert-type P12 --cert %LOCAL_DEBUG_CERTIFICATE_FILE% ^
   --request PUT --http1.1 ^
   --url %CUSTOM_ENDPOINT%/%REQUEST_PATH%?code=%CUSTOM_RP_SECRET_CODE% ^
   --header "Content-Type: application/json" ^
   --data "{\"properties\":{\"database\":\"%DB_NAME%\"}}"
