@echo off
setlocal
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -STA -File "%~dp0app\Start-ProductEntryApp.ps1"
if errorlevel 1 (
    echo.
    echo The Product Entry app could not start.
    echo Copy the error above and send it for troubleshooting.
    echo.
    pause
)
