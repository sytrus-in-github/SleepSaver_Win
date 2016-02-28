@echo off

if EXIST "%~dp0\OFF" rm -f "%~dp0\OFF"
if EXIST "%~dp0\STOP" rm -f "%~dp0\STOP"
rm -f "%~dp0\CURR_TIME"

schtasks /delete /tn "autoShutDown" /f
schtasks /delete /tn "autoShutDownAlert" /f
schtasks /delete /tn "autoShutDownRestore" /f
