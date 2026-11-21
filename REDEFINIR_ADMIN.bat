@echo off
setlocal
cd /d "%~dp0SIGEV_Web"
if not exist "runtime\node.exe" echo SIGEV ainda nao foi instalado. Execute INSTALAR_SIGEV.bat & pause & exit /b 1
set "DATA_DIR=%CD%\data"
set "PATH=%CD%\runtime;%PATH%"
echo.
echo Redefinir senha do administrador (minimo 10 caracteres).
set /p NOVA=Nova senha: 
"runtime\node.exe" reset-admin.js "%NOVA%"
echo.
pause
