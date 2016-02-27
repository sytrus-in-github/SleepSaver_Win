# SleepSaver

by Torchlight

## introduction:

This is a bunch of scripts that I use to schedule auto-shutdown so as to win back some of my sleep time :)

3 tasks will be created in Task Scheduler:

* __autoShutDown__:         shut down the computer at a specified time. (default 01:00)
* __autoShutDownAlert__:    Alert the user 1 hour before the shut down and repeat every 15 minutes
* __autoShutDownRestore__:  Reactivate autoShutDown if deactivated, checked after each login.

## usage:

1. To install SleepSaver, set up tasks mentioned above: run __install.vbs__
2. After installation:
  * To change the time of the computer shutdown: run __changeTime.vbs__
  * To switch off _temporarily_ / switch back on: run __switch.vbs__
3. To uninstall SleepSaver, remove tasks mentioned above: run __uninstall.vbs__

__Tested on Windows 7 x64, might work on other Windows systems.__

__Enjoy!__

:flashlight: __Torchlight Present__ :flashlight:
