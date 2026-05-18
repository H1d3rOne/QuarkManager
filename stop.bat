@echo off
chcp 65001 >nul 2>&1
setlocal enabledelayedexpansion

set "BACKEND_PORT=3000"
set "FRONTEND_PORT=8000"

if "%~1"=="" (
    set "TARGET=all"
) else (
    set "TARGET=%~1"
)

if "!TARGET!"=="backend" goto :stop_backend
if "!TARGET!"=="frontend" goto :stop_frontend
if "!TARGET!"=="all" goto :stop_all
goto :usage

:stop_backend
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":%BACKEND_PORT% " ^| findstr "LISTENING"') do (
    echo [INFO] 已停止后端服务 PID: %%a
    taskkill /F /PID %%a >nul 2>&1
)
if "!TARGET!"=="backend" goto :eof
goto :stop_frontend

:stop_frontend
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":%FRONTEND_PORT% " ^| findstr "LISTENING"') do (
    echo [INFO] 已停止前端服务 PID: %%a
    taskkill /F /PID %%a >nul 2>&1
)
if "!TARGET!"=="frontend" goto :eof
goto :done

:stop_all
call :stop_backend
call :stop_frontend

:done
echo [INFO] 所有服务已停止
goto :eof

:usage
echo 用法: %~nx0 {all^|backend^|frontend}
echo   all      - 停止前后端服务 (默认)
echo   backend  - 仅停止后端服务
echo   frontend - 仅停止前端服务
exit /b 1
