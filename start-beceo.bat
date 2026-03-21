@echo off
title BeCEO
echo Starting BeCEO...
beceo start
if %errorlevel% neq 0 (
    echo.
    echo Failed to start BeCEO. Please check your setup or run: beceo check
    pause
)
