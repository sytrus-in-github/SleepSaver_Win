Set objShell = CreateObject("Shell.Application")
If WScript.Arguments.Count = 0 Then
    objShell.ShellExecute "wscript.exe", WScript.ScriptFullName & " Run", , "runas", 1
Else
	strDir = replace( WScript.ScriptFullName, WScript.ScriptName, "" ) & "scripts\"
	Set fso = CreateObject("Scripting.FileSystemObject")
	set oshell = CreateObject("WScript.Shell")
	'if not installed install it
	if not fso.FileExists(strDir & "CURR_TIME") then
			'prompt for user input
			prompt = "Enter auto shutdown time (HH:MM):"
			strTime = InputBox(prompt,"sleepSaver setup","01:00")
			'check input format
			Err.Clear
			On Error Resume Next
			strTime = Trim(strTime)
			if len(strTime) = 0 then
				MsgBox("Empty input. Use default time 01:00.")
				strTime = "01:00"
			end if
			intTime = toMinute(strTime)
			if Err.Number <> 0 then
				MsgBox("Invalid format. Use default time 01:00.")
				intTime = 60
			end if
			'register new time setting in file CURR_TIME
			On Error Goto 0
			strTime = toTime(intTime)
			strT5 = toTime((intTime + 1435) mod 1440)
			strT60 = toTime((intTime + 1380) mod 1440)
			fso.CreateTextFile(strDir & "CURR_TIME")
			Set f = fso.GetFile(strDir & "CURR_TIME").OpenAsTextStream(2, -2)
			f.WriteLine strTime
			f.close
			'change time settings in tasks
			Set f = fso.GetFile(strDir & "install_sleepSaver.bat").OpenAsTextStream(2, -2)
			f.WriteLine "@echo off"
			f.WriteLine "schtasks /create /tn autoShutDown /tr "&chr(34)&"shutdown /s /t 300 /c "&chr(92)&chr(34)&"You need to sleep! Shutdown in 5 minutes."&chr(92)&chr(34)&chr(34)&" /sc daily /st "& strT5
			f.WriteLine "schtasks /create /tn autoShutDownAlert /tr "&chr(34)& left(strDir,len(strDir)-8) &"autoDownAlert.vbs"&chr(34)&" /sc daily /st "&strT60&" /ri 15 /du 0000:55"
			f.WriteLine "schtasks /create /tn "&chr(34)&"autoShutDownRestore"&chr(34)&" /tr "&chr(34)& left(strDir,len(strDir)-8) &"autoDownRestart.vbs"&chr(34)&" /sc ONSTART /ru " & chr(34) & chr(34)
			'deal with TODAY
			if fso.FileExists(strDir & "TODAY") then
				if fso.GetFile(strDir & "TODAY").DateLastModified < dateadd("h", -24, Now) then
					'delete old file
					fso.DeleteFile(strDir & "TODAY")
				else
					'deactivate sleepSaver for today since already scheduled 
					f.WriteLine "schtasks /Change /TN "&chr(34)&"autoShutDown"&chr(34)&" /Disable"
					f.WriteLine "schtasks /Change /TN "&chr(34)&"autoShutDownAlert"&chr(34)&" /Disable"
					f.WriteLine "copy /y NUL "&chr(34)&"%~dp0"&chr(92)&"OFF"&chr(34)&" >NUL"
				end if
			end if
			f.close
			oshell.Run strDir & "install_sleepSaver.bat",0,true
			'check if need to be shut down in less than 5 minutes if so add another 1-time shutdown
			if not fso.FileExists(strDir & "TODAY") then
				intDiff = 60*intTime-getSecond()
				if intDiff > 10 and intDiff < 300 then
					oshell.Run "shutdown /s /t "&CStr(intDiff)&" /c "&chr(34)&"You need to sleep! Shutdown in "&CStr(intDiff)&" seconds."&chr(34),0
				end if
			else
				MsgBox "sleepSaver will be deactivated for today since shutdown schedule exists already for today.", vbInformation
			end if
			MsgBox "Successfully installed sleepSaver with shutdown time " & strTime
			wscript.quit
	end if
	'show configuration panel and read user input
	if fso.FileExists(strDir & "TODAY") then
		if fso.GetFile(strDir & "TODAY").DateLastModified < dateadd("h", -24, Now) then
			'delete old file
			fso.DeleteFile(strDir & "TODAY")
		else
			'launch today.vbs to deal with today functionality
			objShell.ShellExecute left(strDir,len(strDir)-8) & "forToday.vbs"
			wscript.quit
		end if
	else
		if fso.FileExists(strDir & "STOP") then
			prompt = "sleepSaver is deactivated (no auto-reactivation)" & vbcrlf & vbcrlf & _
				"You can:" & vbcrlf & vbcrlf & _
				"1. Set up sleepSaver for today" & vbcrlf & "(will be back to deactivation on restart)"& vbcrlf & vbcrlf & _
				"9. Activate sleepSaver" & vbcrlf & vbcrlf & _
				"0. Uninstall sleepSaver" & vbcrlf & _
				vbcrlf & "Selection(1/9/0):"
		else
			Set f = fso.GetFile(strDir & "CURR_TIME").OpenAsTextStream(1, -2)
			strTime = f.Readline
			f.close
			if fso.FileExists(strDir & "OFF") then
				prompt = "sleepSaver is deactivated for today" & "(will be back to " &strTime& " on restart)"& vbcrlf & vbcrlf & _
				"You can:" & vbcrlf & vbcrlf & _
				"1. Set up sleepSaver for today" & vbcrlf & "(will be back to " &strTime& " on restart)"& vbcrlf & vbcrlf & _
				"2. Turn sleepSaver back on" & vbcrlf & vbcrlf & _
				"9. Deactivate sleepSaver" & vbcrlf & "(no auto-reactivation)" & vbcrlf & vbcrlf & _
				"0. Uninstall sleepSaver" & vbcrlf & _
				vbcrlf & "Selection(1/2/9/0):"
			else	
				prompt = "Current time of auto shutdown: " & strTime & vbcrlf & vbcrlf & _ 
				"You can:" & vbcrlf & vbcrlf & _
				"1. Change shutdown time for today" & vbcrlf & "(will be back to " &strTime& " on restart)"& vbcrlf & vbcrlf & _
				"2. Deactivate sleepSaver for today" & vbcrlf & "(auto-reactivation on restart)" & vbcrlf &  vbcrlf & _
				"3. Change shutdown time" & vbcrlf & vbcrlf & _
				"9. Deactivate sleepSaver" & vbcrlf & "(no auto-reactivation)" & vbcrlf & vbcrlf & _
				"0. Uninstall sleepSaver" & vbcrlf & _
				vbcrlf & "Selection(1/2/3/9/0):"
			end if
		end if
	end if
	choice = InputBox(prompt,"sleepSaver config")
	if choice = "" then
	elseif choice = "1" then
		objShell.ShellExecute left(strDir,len(strDir)-8) & "forToday.vbs"
	elseif choice = "2" and not fso.FileExists(strDir & "STOP") then
		objShell.ShellExecute strDir & "switch.vbs"
	elseif choice = "3" and not fso.FileExists(strDir & "STOP") and not fso.FileExists(strDir & "OFF") then
		objShell.ShellExecute strDir & "changeTime.vbs"
	elseif choice = "9" then
		objShell.ShellExecute strDir & "switchAll.vbs"
	elseif choice = "0" then
		objShell.ShellExecute strDir & "uninstall.vbs"
	else
		MsgBox "Wrong input format."
	end if
End If


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