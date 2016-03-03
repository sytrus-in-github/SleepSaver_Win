Set fso = CreateObject("Scripting.FileSystemObject")
strDir = replace( WScript.ScriptFullName, WScript.ScriptName, "" )

if fso.FileExists(strDir & "TODAY") then
	'deal with TODAY
	if fso.GetFile(strDir & "TODAY").DateLastModified < dateadd("h", -24, Now) then
		fso.DeleteFile(strDir & "TODAY")
	end if
else
	'switch back on sleepSaver
	if fso.FileExists(strDir & "OFF") then
		set oshell = CreateObject("WScript.Shell")
		oshell.Run strDir & "autoDownSwitch.bat",0,true
	end if
end if