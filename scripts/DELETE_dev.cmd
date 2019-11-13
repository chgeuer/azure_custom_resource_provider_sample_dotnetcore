@echo off

call %~dp0vars.cmd

%USERPROFILE%\bin\curl.exe ^
   --verbose --include ^
   --cert-type P12 --cert %cert% ^
   --request DELETE --http1.1 ^
   --url %customEndpoint%%P%?code=%code%
