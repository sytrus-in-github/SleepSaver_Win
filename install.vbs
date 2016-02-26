Set objShell = CreateObject("Shell.Application")
If WScript.Arguments.Count = 0 Then
	're-run this script as admin 
    objShell.ShellExecute "wscript.exe", WScript.ScriptFullName & " Run", , "runas", 1
Else
	'get current path
	strDir = replace( WScript.ScriptFullName, WScript.ScriptName, "" )
	'register default time setting
	Set fso = CreateObject("Scripting.FileSystemObject")
	Set f = fso.CreateTextFile(strDir & "scripts\CURR_TIME", True, True)
	'f.WriteLine("t0="&chr(34)&"01:00"&chr(34) & vbcrlf &"t5="&chr(34)&"00:55"&chr(34) & vbcrlf&"t60="&chr(34)&"00:00"&chr(34)&vbcrlf)
	f.writeline("01:00")
	f.Close
	'launch installation batch file as admin
	objShell.ShellExecute strDir & "scripts\install_sleepSaver.bat"
End If