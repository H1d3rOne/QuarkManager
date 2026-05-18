@echo off
chcp 65001 >nul 2>&1
setlocal enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"
set "BACKEND_DIR=%SCRIPT_DIR%backend"
set "FRONTEND_DIR=%SCRIPT_DIR%frontend"
set "VENV_DIR=%BACKEND_DIR%\.venv"
set "BACKEND_PORT=3000"
set "FRONTEND_PORT=8000"

if "%~1"=="" (
    set "TARGET=all"
) else (
    set "TARGET=%~1"
)

if "!TARGET!"=="backend" goto :start_backend
if "!TARGET!"=="frontend" goto :start_frontend
if "!TARGET!"=="all" goto :start_all
goto :usage

:setup_venv
if exist "!VENV_DIR!\Scripts\activate.bat" (
    goto :eof
)

echo [INFO] 虚拟环境不存在，正在创建...

where uv >nul 2>&1
if %ERRORLEVEL% equ 0 (
    echo [INFO] 使用 uv 创建虚拟环境...
    cd /d "!BACKEND_DIR!"
    uv venv
    echo [INFO] 使用 uv 安装依赖...
    uv pip install -r requirements.txt
    cd /d "!SCRIPT_DIR!"
) else (
    where python >nul 2>&1
    if %ERRORLEVEL% neq 0 (
        where python3 >nul 2>&1
        if %ERRORLEVEL% neq 0 (
            echo [ERROR] 未找到 uv 或 Python，请先安装
            exit /b 1
        )
        set "PYTHON_CMD=python3"
    ) else (
        set "PYTHON_CMD=python"
    )
    echo [INFO] 使用 !PYTHON_CMD! 创建虚拟环境...
    cd /d "!BACKEND_DIR!"
    !PYTHON_CMD! -m venv .venv
    call .venv\Scripts\activate.bat
    pip install -r requirements.txt
    call deactivate
    cd /d "!SCRIPT_DIR!"
)

echo [INFO] 虚拟环境创建完成
goto :eof

:start_backend
echo [INFO] 启动后端服务...

for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":%BACKEND_PORT% " ^| findstr "LISTENING"') do (
    echo [WARN] 端口 %BACKEND_PORT% 已被占用，正在关闭 PID: %%a
    taskkill /F /PID %%a >nul 2>&1
    timeout /t 1 /nobreak >nul
)

call :setup_venv

cd /d "!BACKEND_DIR!"
start "QuarkManager-Backend" cmd /c ".venv\Scripts\activate.bat && python -m uvicorn app.main:app --host 0.0.0.0 --port %BACKEND_PORT% --reload"
cd /d "!SCRIPT_DIR!"

timeout /t 2 /nobreak >nul
echo [INFO] 后端服务已启动 http://localhost:%BACKEND_PORT%

if "!TARGET!"=="backend" goto :eof
goto :start_frontend

:start_frontend
echo [INFO] 启动前端服务...

for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":%FRONTEND_PORT% " ^| findstr "LISTENING"') do (
    echo [WARN] 端口 %FRONTEND_PORT% 已被占用，正在关闭 PID: %%a
    taskkill /F /PID %%a >nul 2>&1
    timeout /t 1 /nobreak >nul
)

if not exist "!FRONTEND_DIR!\node_modules\" (
    echo [INFO] 首次运行，安装前端依赖...
    cd /d "!FRONTEND_DIR!"
    call npm install
    cd /d "!SCRIPT_DIR!"
)

cd /d "!FRONTEND_DIR!"
start "QuarkManager-Frontend" cmd /c "npm run dev"
cd /d "!SCRIPT_DIR!"

timeout /t 2 /nobreak >nul
echo [INFO] 前端服务已启动 http://localhost:%FRONTEND_PORT%

if "!TARGET!"=="frontend" goto :eof
goto :done

:start_all
call :start_backend
call :start_frontend

:done
echo.
echo =========================================
echo   QuarkManager 服务已启动
echo   后端 API:  http://localhost:%BACKEND_PORT%
echo   前端页面:  http://localhost:%FRONTEND_PORT%
echo   API 文档:  http://localhost:%BACKEND_PORT%/docs
echo =========================================
echo.
echo 关闭此窗口不会停止服务，请使用 stop.bat 停止服务
goto :eof

:usage
echo 用法: %~nx0 {all^|backend^|frontend}
echo   all      - 启动前后端服务 (默认)
echo   backend  - 仅启动后端服务
echo   frontend - 仅启动前端服务
exit /b 1
