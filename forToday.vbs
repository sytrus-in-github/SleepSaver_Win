set objShell = CreateObject("Shell.Application")
if WScript.Arguments.Count = 0 then
    objShell.ShellExecute "wscript.exe", WScript.ScriptFullName & " Run", , "runas", 1
else
	Set fso = CreateObject("Scripting.FileSystemObject")
	strDir = replace( WScript.ScriptFullName, WScript.ScriptName, "" ) & "scripts\"
	'delete old file 
	if fso.FileExists(strDir & "TODAY") then
		Set f = fso.GetFile(strDir & "TODAY")
		if f.DateLastModified < dateadd("h", -24, Now) then
			fso.DeleteFile(strDir & "TODAY")
		end if
	end if
	set oshell = CreateObject("WScript.Shell")
	if not fso.FileExists(strDir & "TODAY") then'if no TODAY sign 
		intTime = buildToday()
		strTime = toTime(intTime)
		strT5 = toTime((intTime + 1435) mod 1440)
		'if exists running sleepSaver procedure deactivate 
		if fso.FileExists(strDir & "CURR_TIME") and not fso.FileExists(strDir & "OFF") and not fso.FileExists(strDir & "STOP") then
			oshell.Run strDir & "autoDownSwitch.bat",0,true
			'objShell.ShellExecute strDir & "switch.vbs"
		end if
		'create new scheduled task,
		Set f = fso.GetFile(strDir & "forToday.bat").OpenAsTextStream(2, -2)
		f.WriteLine "@echo off"
		f.WriteLine "schtasks /create /tn autoShutDownForToday /tr "&chr(34)&"shutdown /s /t 300 /c "&chr(92)&chr(34)&"You need to sleep! Shutdown in 5 minutes."&chr(92)&chr(34)&chr(34)&" /sc once /st "& strT5
		f.close
		oshell.Run strDir & "forToday.bat",0,true
		MsgBox("Auto shutdown at " & strTime &" for today")
	else'prompt for user choice according to CURR_TIME, OFF and STOP sign
		'read time
		Set f = fso.GetFile(strDir & "TODAY").OpenAsTextStream(1, -2)
		strTime = f.Readline
		f.close
		prompt = "Time of auto shutdown for today: " & strTime & vbcrlf & vbcrlf & _ 
			"You can:" & vbcrlf & vbcrlf & _
			"1. Change shutdown time for today" & vbcrlf & vbcrlf & _
			"2. Deactivate shutdown for today" & vbcrlf &  vbcrlf
		if fso.FileExists(strDir & "CURR_TIME") then
			Set f = fso.GetFile(strDir & "CURR_TIME").OpenAsTextStream(1, -2)
			strTime = f.Readline
			f.close
			prompt = prompt & "3. Turn back to " & strTime & " every day" & vbcrlf & "(current sleepSaver setting)" & vbcrlf
		end if
		prompt = prompt & vbcrlf & "Selection(1/2/3):"
		'generate corresponding batch and execute
		choice = InputBox(prompt,"sleepSaver config (for today)")
		if choice = "1" then
			intTime = buildToday()
			strTime = toTime(intTime)
			strT5 = toTime((intTime + 1435) mod 1440)
			Set f = fso.GetFile(strDir & "forToday.bat").OpenAsTextStream(2, -2)
			f.WriteLine "@echo off"
			f.WriteLine "schtasks /delete /tn autoShutDownForToday /f"
			f.WriteLine "schtasks /create /tn autoShutDownForToday /tr "&chr(34)&"shutdown /s /t 300 /c "&chr(92)&chr(34)&"You need to sleep! Shutdown in 5 minutes."&chr(92)&chr(34)&chr(34)&" /sc once /st "& strT5
			f.close
			oshell.Run strDir & "forToday.bat",0,true
			MsgBox("Auto shutdown changed to " & strTime &" for today")
		elseif choice = "2" then
			Set f = fso.GetFile(strDir & "forToday.bat").OpenAsTextStream(2, -2)
			f.WriteLine "@echo off"
			f.WriteLine "schtasks /delete /tn autoShutDownForToday /f"
			f.WriteLine "rm -f " & chr(34) & "%~dp0\TODAY" & chr(34)
			f.close
			oshell.Run strDir & "forToday.bat",0,true
			MsgBox("Auto shutdown for today is turned off.")
		elseif choice = "3" then
			Set f = fso.GetFile(strDir & "forToday.bat").OpenAsTextStream(2, -2)
			f.WriteLine "@echo off"
			f.WriteLine "schtasks /delete /tn autoShutDownForToday /f"
			f.WriteLine"rm -f " & chr(34) & "%~dp0\TODAY" & chr(34)
			f.close
			oshell.Run strDir & "forToday.bat",0,true
			if fso.FileExists(strDir & "OFF") then
				objShell.ShellExecute strDir & "switch.vbs"
			elseif fso.FileExists(strDir & "STOP") then
				objShell.ShellExecute strDir & "switchAll.vbs"
			end if
		elseif choice = "" then
		else
			MsgBox "Wrong input format."
		end if
	end if
end if

function buildToday()
	'prompt for time, 
		prompt = "Enter auto shutdown time for today(HH:MM):"
		strTime = InputBox(prompt,"sleepSaver setup","01:00")
		'check input format
		Err.Clear
		On Error resume next
		strTime = Trim(strTime)
		if len(strTime) = 0 then
			MsgBox "Empty input. Operation aborted."
			wscript.quit
		end if
		buildToday = toMinute(strTime)
		if Err.Number <> 0 then
			MsgBox "Invalid format. Operation aborted."
			wscript.quit
		end if
		'register new time setting in file CURR_TIME
		On Error Goto 0
		fso.CreateTextFile(strDir & "TODAY")
		Set f = fso.GetFile(strDir & "TODAY").OpenAsTextStream(2, -2)
		f.WriteLine toTime(buildToday)
		f.close
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

