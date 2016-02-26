@echo off

if EXIST "%~dp0\OFF" rm -f "%~dp0\OFF"

schtasks /delete /tn "autoShutDown" /f
schtasks /delete /tn "autoShutDownAlert" /f
schtasks /delete /tn "autoShutDownRestore" /f

echo.
echo uninstallation finished.

pause