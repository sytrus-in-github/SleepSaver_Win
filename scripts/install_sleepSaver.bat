@echo off

if EXIST "%~dp0\OFF" rm -f "%~dp0\OFF"

schtasks /create /tn "autoShutDown" /tr "shutdown /s /t 300 /c You need to sleep!" /sc daily /st 00:55
echo task autoshutdown set

schtasks /create /tn "autoShutDownAlert" /tr "%~dp0\autoDownAlert.bat" /sc daily /st 00:00 /ri 15 /et 00:46
echo task autoshutdown alert set

schtasks /create /tn "autoShutDownRestore" /tr "%~dp0\autoDownRestart.bat" /sc onlogon /ru ""
echo task autoshutdown auto-restore set

echo.
echo installation finished.

pause