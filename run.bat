@echo off
chcp 65001 >nul
title WorkBuddy Prompt Tool
cd /d "%~dp0"

echo.
echo ==========================================
echo    WorkBuddy Prompt Tool  -  Windows
echo ==========================================
echo.
echo   [1] One-click inject preset prompt
echo   [2] Extract templates  (edit manually)
echo   [3] Inject changes     (apply)
echo   [4] Restore official   (restore)
echo   [5] Check status       (status)
echo   [6] Find cache folder  (find)
echo   [0] Exit
echo.
set /p choice=Select an option (0-6):

if "%choice%"=="1" set cmd=inject
if "%choice%"=="2" set cmd=extract
if "%choice%"=="3" set cmd=apply
if "%choice%"=="4" set cmd=restore
if "%choice%"=="5" set cmd=status
if "%choice%"=="6" set cmd=find
if "%choice%"=="0" exit

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0wb-prompt.ps1" %cmd%
echo.
pause
