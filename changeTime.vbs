Set objShell = CreateObject("Shell.Application")

if WScript.Arguments.Count = 0 then
    objShell.ShellExecute "wscript.exe", WScript.ScriptFullName & " Run", , "runas", 1
else
	'get current path and script interpreter
	strDir = replace(WScript.ScriptFullName, WScript.ScriptName, "")
	strApp = UCase(Right(WScript.FullName, 12))
	'load current time setting
	Set fso = CreateObject("Scripting.FileSystemObject")
	Set f = fso.GetFile(strDir & "scripts\CURR_TIME").OpenAsTextStream(1, -2)
	strTime = f.Readline
	strTime = Right(strTime,5)
	f.close
	'prompt for user input
	prompt = "Current time of auto shutdown: " + strTime + vbcrlf + "Enter new time (HH:MM, or nothing to discard operation):" + vbcrlf
	if strApp = "\CSCRIPT.EXE" then
		WScript.StdOut.Write prompt
		strTime = WScript.StdIn.ReadLine()
	else
		strTime = InputBox(prompt)
	end if
	'check input format
	Err.Clear
	On Error Resume Next
	strTime = Trim(strTime)
	if len(strTime) = 0 then
		if strApp = "\CSCRIPT.EXE" then
			WScript.Echo vbcrlf & "Empty input. No change performed." & vbcrlf
			WScript.Echo "Press Enter to continue"
			WScript.StdIn.Read(1)
		else
			MsgBox("Empty input. No change performed.")
		end if
		wscript.quit
	end if
	intPos = InStr(strTime,":")
	if intPos < 2 then 
		Err.Raise 5
	end if
	strHour = Left(strTime, intPos-1)
	strMin = Right(strTime, len(strTime)-intPos)
	if not IsNumeric(strHour) or not IsNumeric(strMin) then 
		Err.Raise 5
	end if
	intHour = CInt(strHour)
	intMin = Cint(strMin)
	if intHour < 0 or intMin < 0 then
		Err.Raise 5
	end if
	intHour = intHour mod 24
	intMin = intMin mod 60
	if Err.Number <> 0 then
		if strApp = "\CSCRIPT.EXE" then
			WScript.Echo vbcrlf & "Invalid format. Unsuccesful change." & vbcrlf
			WScript.Echo "Press Enter to continue"
			WScript.StdIn.Read(1)
		else
			MsgBox("Invalid format. Unsuccesful change.")
		end if
		wscript.quit
	end if
	'register new time setting in file CURR_TIME
	On Error Goto 0
	strTime = format(intHour) & ":" & format(intMin)
	if intMin < 5 then
		strHour = format((intHour + 23) mod 24)
		strMin = format((intMin + 55) mod 60)
	else
		strHour = format(intHour)
		strMin = format(intMin - 5)
	end if
	strT5 = strHour & ":" & strMin
	strT60 = format((intHour + 23) mod 24) & ":" & format(intMin)
	Set f = fso.GetFile(strDir & "scripts\CURR_TIME").OpenAsTextStream(2, -2)
	f.WriteLine strTime
	f.close
	'change time settings in tasks
	Set f = fso.GetFile(strDir & "scripts\setTime.bat").OpenAsTextStream(2, -2)
	f.WriteLine "@echo off"
	f.WriteLine "schtasks /delete /tn autoShutDown /f"
	f.WriteLine "schtasks /delete /tn autoShutDownAlert /f"
	f.WriteLine "schtasks /create /tn autoShutDown /tr "&chr(34)&"shutdown /s /t 300 /c "&chr(92)&chr(34)&"You need to sleep!"&chr(92)&chr(34)&chr(34)&" /sc daily /st "& strT5
	f.WriteLine "schtasks /create /tn autoShutDownAlert /tr "&chr(34)&"%~dp0\autoDownAlert.bat"&chr(34)&" /sc daily /st "&strT60&" /ri 15 /du 0000:55"
	f.WriteLine "echo."
	f.WriteLine "echo auto shutdown time set to:"
	f.WriteLine "echo."
	f.WriteLine "type "&chr(34)&"%~dp0\CURR_TIME"&chr(34)
	f.WriteLine "echo."
	f.WriteLine "pause"
	f.close
	objShell.ShellExecute strDir & "scripts\setTime.bat"
end if

function format(s)
	dim str 
	str = Cstr(s)
	if len(str) = 0 then
		format = "00"
	elseif len(str) = 1 then
		format = "0" & str
	else
		format = str
	end if
end function
