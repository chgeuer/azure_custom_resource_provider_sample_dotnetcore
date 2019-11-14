@echo off

call %~dp0vars.cmd

%USERPROFILE%\bin\curl.exe ^
   --verbose --include ^
   --cert-type P12 --cert %cert% ^
   --request DELETE --http1.1 ^
   --url %CUSTOM_ENDPOINT%/%REQUEST_PATH%/%dbname%?code=%CUSTOM_RP_SECRET_CODE%


