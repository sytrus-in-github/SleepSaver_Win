@echo off
if NOT EXIST "%~dp0\OFF" (goto _ON) else (goto _OFF)
:_ON
shutdown -a
schtasks /Change /TN "autoShutDown" /Disable
schtasks /Change /TN "autoShutDownAlert" /Disable
copy /y NUL "%~dp0\OFF" >NUL
goto _EXIT
:_OFF
schtasks /Change /TN "autoShutDown" /Enable
schtasks /Change /TN "autoShutDownAlert" /Enable
rm -f "%~dp0\OFF"
:_EXIT

