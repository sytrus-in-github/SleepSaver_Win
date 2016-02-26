# SleepSaver

by Torchlight

This is a bunch of scripts that I use to schedule auto-shutdown so as to win back some of my sleep time :)

3 tasks will be created in Task Scheduler:
* __autoShutDown__:         shut down the computer at a specified time. (default 01:00)
* __autoShutDownAlert__:    Alert the user 1 hour before the shut down and reappear each 15 mins
* __autoShutDownRestore__:  Reactivate autoShutDown if needed, checked after each login.

## usage:

* To install SleepSaver, set up tasks mentioned above: run __install.vbs__
* To switch off _temporarily_ / switch back on: run __switch.vbs__
* To uninstall SleepSaver, remove tasks mentioned above: run __uninstall.vbs__
