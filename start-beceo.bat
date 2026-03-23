@echo off
chcp 65001 >nul

:: Auto-elevate to admin if needed
net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: Clear any stuck Task Scheduler entry
schtasks /Delete /F /TN "OpenClaw Gateway" >nul 2>&1

:: Check if setup is complete, show GUI setup if not
if not exist "%USERPROFILE%\.openclaw\openclaw.json" (
    powershell -ExecutionPolicy Bypass -File "%~dp0setup-gui.ps1"
    if %errorlevel% neq 0 (
        powershell -Command "[System.Windows.Forms.MessageBox]::Show('Setup failed or was cancelled. Please run BeCEO again to retry.','BeCEO','OK','Warning')" >nul 2>&1
        exit /b 1
    )
)

:: Start BeCEO (refresh PATH first so beceo is found)
powershell -WindowStyle Hidden -Command "$env:Path = [System.Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [System.Environment]::GetEnvironmentVariable('Path','User'); beceo start"
