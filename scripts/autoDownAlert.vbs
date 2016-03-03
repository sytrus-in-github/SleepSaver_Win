Set fso = CreateObject("Scripting.FileSystemObject")
Set f = fso.GetFile(strDir & "CURR_TIME").OpenAsTextStream(1, -2)
strTime = f.Readline
f.close
MsgBox "Time to go to bed." & vbCrLf & vbCrLf & _
	"Current time: " + FormatDateTime(time) & vbCrLf & vbCrLf & _
	"Shutdown at: " & strTime, vbInformation