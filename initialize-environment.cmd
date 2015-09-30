@ECHO OFF
PUSHD %~dp0
PowerShell.exe -NoProfile -ExecutionPolicy Bypass -Command "& './scripts/initialize-environment.ps1'"

IF %errorlevel% neq 0 PAUSE