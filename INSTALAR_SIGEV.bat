@echo off
setlocal
cd /d "%~dp0"
title Instalar SIGEV - Externato Victoria
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0INSTALAR_SIGEV.ps1"
if errorlevel 1 echo Instalacao interrompida. Veja a mensagem de erro acima.
echo.
pause
