@echo off
chcp 65001 >nul

:: Auto-elevate to admin if needed
net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: Check if setup is complete, show GUI setup if not
if not exist "%USERPROFILE%\.openclaw\openclaw.json" (
    powershell -ExecutionPolicy Bypass -WindowStyle Hidden -File "%~dp0setup-gui.ps1"
)

:: Start BeCEO silently
powershell -WindowStyle Hidden -Command "beceo start"
