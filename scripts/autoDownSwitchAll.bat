@echo off
if NOT EXIST "%~dp0\STOP" (goto _ON) else (goto _OFF)
:_ON
shutdown -a
schtasks /Change /TN "autoShutDown" /Disable
schtasks /Change /TN "autoShutDownAlert" /Disable
schtasks /Change /TN "autoShutDownRestore" /Disable
if EXIST "%~dp0\OFF" rm -f "%~dp0\OFF"
touch "%~dp0\STOP"
goto _EXIT
:_OFF
schtasks /Change /TN "autoShutDown" /Enable
schtasks /Change /TN "autoShutDownAlert" /Enable
schtasks /Change /TN "autoShutDownRestore" /Enable
rm -f "%~dp0\STOP"
:_EXIT