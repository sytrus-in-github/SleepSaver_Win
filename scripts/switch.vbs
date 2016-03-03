Set objShell = CreateObject("Shell.Application")
If WScript.Arguments.Count = 0 Then
    objShell.ShellExecute "wscript.exe", WScript.ScriptFullName & " Run", , "runas", 1
Else
	strDir = replace( WScript.ScriptFullName, WScript.ScriptName, "" )
	set oshell = CreateObject("WScript.Shell")
	oshell.Run strDir & "autoDownSwitch.bat",0,true
	Set fso = CreateObject("Scripting.FileSystemObject")
	if fso.FileExists(strDir & "OFF") then
		MsgBox "sleepSaver OFF temporarily, will be reactivated on restart."
	else
		Set f = fso.GetFile(strDir & "CURR_TIME").OpenAsTextStream(1, -2)
		strTime = f.Readline
		f.close
		MsgBox "sleepSaver back ON for " & strTime
	end if
End If

