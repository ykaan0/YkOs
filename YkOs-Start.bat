@echo off
title Launching YkOs Virtual Machine...
echo ========================================================
echo               YkOs Vulnerable Lab System
echo ========================================================
echo Starting virtual machine...

"C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" startvm "YkOs" --type gui

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [!] If YkOs has not been registered yet, please run YkOs-Setup.bat first.
    pause
)
