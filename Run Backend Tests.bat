@echo off
setlocal
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0tests\Invoke-ProductEntryStore.Tests.ps1"
echo.
pause
