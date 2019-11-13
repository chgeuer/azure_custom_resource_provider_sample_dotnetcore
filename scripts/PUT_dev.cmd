@echo off

call %~dp0vars.cmd

%USERPROFILE%\bin\curl.exe ^
   --verbose --include ^
   --cert-type P12 --cert %cert% ^
   --request PUT --http1.1 ^
   --url %customEndpoint%%P%?code=%code% ^
   --header "Content-Type: application/json" ^
   --data "{\"properties\":{\"database\":\"%dbname%\"}}"
