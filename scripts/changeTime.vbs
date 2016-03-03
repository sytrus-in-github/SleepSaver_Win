Set objShell = CreateObject("Shell.Application")

if WScript.Arguments.Count = 0 then
    objShell.ShellExecute "wscript.exe", WScript.ScriptFullName & " Run", , "runas", 1
else
	'get current path and script interpreter
	strDir = replace(WScript.ScriptFullName, WScript.ScriptName, "")
	'load current time setting
	Set fso = CreateObject("Scripting.FileSystemObject")
	Set f = fso.GetFile(strDir & "CURR_TIME").OpenAsTextStream(1, -2)
	strTime = f.Readline
	f.close
	'prompt for user input
	prompt = "Current time of auto shutdown: " & strTime & vbcrlf & "Enter new time (HH:MM, or nothing to discard operation):" & vbcrlf
	strTime = InputBox(prompt,,strTime)
	'check input format
	Err.Clear
	On Error Resume Next
	strTime = Trim(strTime)
	if len(strTime) = 0 then
		MsgBox("Empty input. No change performed.")
		wscript.quit
	end if
	intTime = toMinute(strTime)
	if Err.Number <> 0 then
		MsgBox("Invalid format. Unsuccesful change.")
		wscript.quit
	end if
	'register new time setting in file CURR_TIME
	On Error Goto 0
	strTime = toTime(intTime)
	strT5 = toTime((intTime + 1435) mod 1440)
	strT60 = toTime((intTime + 1380) mod 1440)
	Set f = fso.GetFile(strDir & "CURR_TIME").OpenAsTextStream(2, -2)
	f.WriteLine strTime
	f.close
	'change time settings in tasks
	Set f = fso.GetFile(strDir & "setTime.bat").OpenAsTextStream(2, -2)
	f.WriteLine "@echo off"
	f.WriteLine "schtasks /delete /tn autoShutDown /f"
	f.WriteLine "schtasks /delete /tn autoShutDownAlert /f"
	f.WriteLine "schtasks /create /tn autoShutDown /tr "&chr(34)&"shutdown /s /t 300 /c "&chr(92)&chr(34)&"You need to sleep! Shutdown in 5 minutes."&chr(92)&chr(34)&chr(34)&" /sc daily /st "& strT5
	f.WriteLine "schtasks /create /tn autoShutDownAlert /tr "&chr(34)&"%~dp0\autoDownAlert.bat"&chr(34)&" /sc daily /st "&strT60&" /ri 15 /du 0000:55"
	f.close
	set oshell = CreateObject("WScript.Shell")
	oshell.Run strDir & "setTime.bat",0,true
	'check if need to be shut down in less than 5 minutes if so add another 1 timer
	intDiff = 60*intTime-getSecond()
	if intDiff > 0 and intDiff < 300 then
		oshell.Run "shutdown /s /t "&CStr(intDiff)&" /c "&chr(34)&"You need to sleep! Shutdown in "&CStr(intDiff)&" seconds."&chr(34),0
	else
		MsgBox("Successfully changed shutdown time to " & strTime)
	end if
end if

'turn hh:mm:ss to seconds
function getSecond()
	getSecond = Hour(now)*3600+Minute(now)*60+Second(now)
end function

'turn hh:mm to minutes
function toMinute(str)
	intPos = InStr(str,":")
	if intPos < 2 then 
		Err.Raise 5
	end if
	strHour = Left(str, intPos-1)
	strMin = Right(str, len(str)-intPos)
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
	toMinute = intMin+60*intHour
end function

'turn minutes(integer) to format hh:mm
function toTime(s)
	intHour = s \ 60
	intMin = s mod 60
	toTime = format(intHour) & ":" & format(intMin)
end function

'turn number to form DD with leading 0 if needed
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
