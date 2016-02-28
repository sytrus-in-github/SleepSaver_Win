Set objShell = CreateObject("Shell.Application")
If WScript.Arguments.Count = 0 Then
    objShell.ShellExecute "wscript.exe", WScript.ScriptFullName & " Run", , "runas", 1
Else
	strDir = replace( WScript.ScriptFullName, WScript.ScriptName, "" )
	set oshell = CreateObject("WScript.Shell")
	oshell.Run strDir & "uninstall_sleepSaver.bat",0,true
	MsgBox "Uninstallation of sleepSaver completed."
End If