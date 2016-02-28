# SleepSaver

by Torchlight

## introduction:

This is a bunch of scripts that I use to schedule auto-shutdown so as to win back some of my sleep time :)

sleepSaver will shutdown automatically your computer every day at a specified time. You will be informed an hour before the shutdown and the reminder will repeat every 15 minutes. You are free to change shutdown time and turn it off.  

3 tasks will be created in Task Scheduler:

* __autoShutDown__:         shut down the computer at a specified time. (default 01:00 with 5 minutes final countdown.)
* __autoShutDownAlert__:    Alert the user 1 hour before the shut down and repeat every 15 minutes
* __autoShutDownRestore__:  Reactivate autoShutDown if deactivated, checked after each login.

## usage:

* __sleepSaver.vbs__: for install / configuration / uninstall

## independent utility

* __stopShutDown.bat__: turns off the final countdown. (faster to double click this than type `shutdown -a` in console)

## special thanks to:

@supercontact for being the first tester and pointing out the bug which omits the first shutdown if in less than 5 minutes.

__Tested on Windows 7 x64, might work on other Windows systems.__

__Enjoy!__

:flashlight: __Torchlight Present__ :flashlight:
