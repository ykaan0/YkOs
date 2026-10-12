@echo off
title YkOs Setup (VirtualBox)
echo ========================================================
echo        YkOs Automatic Setup and Configuration
echo ========================================================
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Create-YkOs-VM.ps1"
pause
