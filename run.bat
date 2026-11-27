@echo off
chcp 65001 >nul
title WorkBuddy Prompt Tool
cd /d "%~dp0"

echo.
echo ==========================================
echo    WorkBuddy Prompt Tool  -  Windows
echo ==========================================
echo.
echo   [1] Extract templates  (extract)
echo   [2] Inject changes     (apply)
echo   [3] Restore official   (restore)
echo   [4] Check status       (status)
echo   [0] Exit
echo.
set /p choice=Select an option (0-4):

if "%choice%"=="1" set cmd=extract
if "%choice%"=="2" set cmd=apply
if "%choice%"=="3" set cmd=restore
if "%choice%"=="4" set cmd=status
if "%choice%"=="0" exit

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0wb-prompt.ps1" %cmd%
echo.
pause
