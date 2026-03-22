@echo off
title BeCEO

:: Step 1: Clear any stuck Task Scheduler entry
schtasks /Delete /F /TN "OpenClaw Gateway" >nul 2>&1

:: Step 2: Check if setup has been completed
if not exist "%USERPROFILE%\.openclaw\openclaw.json" (
    echo BeCEO setup has not been completed. Starting setup wizard...
    echo.
    beceo setup
    if %errorlevel% neq 0 (
        echo.
        echo Setup failed or was interrupted. Please run this launcher again to retry.
        pause
        exit /b 1
    )
    echo.
    echo Setup complete! Starting BeCEO...
    echo.
)

:: Step 3: Start BeCEO
beceo start
if %errorlevel% neq 0 (
    echo.
    echo Failed to start BeCEO. Please check your setup or run: beceo check
    pause
)
