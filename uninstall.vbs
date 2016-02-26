Set objShell = CreateObject("Shell.Application")
If WScript.Arguments.Count = 0 Then
    objShell.ShellExecute "wscript.exe", WScript.ScriptFullName & " Run", , "runas", 1
Else
	strDir = replace( WScript.ScriptFullName, WScript.ScriptName, "" )
	objShell.ShellExecute strDir & "scripts\uninstall_sleepSaver.bat"
End If