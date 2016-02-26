@echo off
if NOT EXIST "%~dp0\OFF" (goto _ON) else (goto _OFF)
:_ON
shutdown -a
schtasks /Change /TN "autoShutDown" /Disable
schtasks /Change /TN "autoShutDownAlert" /Disable
if ERRORLEVEL 1 (goto _ERROR) 
touch "%~dp0\OFF"
echo current status: OFF
goto _EXIT
:_OFF
schtasks /Change /TN "autoShutDown" /Enable
schtasks /Change /TN "autoShutDownAlert" /Enable
if ERRORLEVEL 1 (goto _ERROR) 
rm -f "%~dp0\OFF"
echo current status: ON
goto _EXIT
:_ERROR
echo Unsuccessful operation: UAC required. 
:_EXIT
pause
