Option Explicit

Dim shell, fileSystem, scriptDirectory, appScript, command

Set shell = CreateObject("WScript.Shell")
Set fileSystem = CreateObject("Scripting.FileSystemObject")

scriptDirectory = fileSystem.GetParentFolderName(WScript.ScriptFullName)
appScript = scriptDirectory & "\app\Start-ProductEntryApp.ps1"

shell.CurrentDirectory = scriptDirectory
command = "powershell.exe -NoProfile -ExecutionPolicy Bypass -STA -WindowStyle Hidden -File " & Chr(34) & appScript & Chr(34)

shell.Run command, 0, False