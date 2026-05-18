$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$BackendDir = Join-Path $ScriptDir "backend"
$FrontendDir = Join-Path $ScriptDir "frontend"
$VenvDir = Join-Path $BackendDir ".venv"
$BackendPort = 3000
$FrontendPort = 8000

function Write-Info($msg)  { Write-Host "[INFO] " -ForegroundColor Green -NoNewline; Write-Host $msg }
function Write-Warn($msg)  { Write-Host "[WARN] " -ForegroundColor Yellow -NoNewline; Write-Host $msg }
function Write-Err($msg)   { Write-Host "[ERROR] " -ForegroundColor Red -NoNewline; Write-Host $msg }

function Stop-Port($port) {
    $conn = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue | Where-Object { $_.State -eq "Listen" }
    if ($conn) {
        $pid = $conn.OwningProcess
        Write-Warn "端口 $port 已被占用，正在关闭 PID: $pid"
        Stop-Process -Id $pid -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 1
    }
}

function Setup-Venv {
    $activateScript = Join-Path $VenvDir "Scripts\Activate.ps1"
    if (Test-Path $activateScript) { return }

    Write-Info "虚拟环境不存在，正在创建..."

    if (Get-Command uv -ErrorAction SilentlyContinue) {
        Write-Info "使用 uv 创建虚拟环境..."
        Push-Location $BackendDir
        uv venv
        Write-Info "使用 uv 安装依赖..."
        uv pip install -r requirements.txt
        Pop-Location
    } elseif (Get-Command python -ErrorAction SilentlyContinue -or Get-Command python3 -ErrorAction SilentlyContinue) {
        $py = if (Get-Command python -ErrorAction SilentlyContinue) { "python" } else { "python3" }
        Write-Info "使用 $py 创建虚拟环境..."
        Push-Location $BackendDir
        & $py -m venv .venv
        & $activateScript
        pip install -r requirements.txt
        deactivate
        Pop-Location
    } else {
        Write-Err "未找到 uv 或 Python，请先安装"
        exit 1
    }

    Write-Info "虚拟环境创建完成"
}

function Start-Backend {
    Write-Info "启动后端服务..."
    Stop-Port $BackendPort

    Setup-Venv

    $activateScript = Join-Path $VenvDir "Scripts\Activate.ps1"
    Push-Location $BackendDir
    Start-Process -FilePath "powershell" -ArgumentList "-NoExit", "-Command", "& { `".\$activateScript`"; python -m uvicorn app.main:app --host 0.0.0.0 --port $BackendPort --reload }"
    Pop-Location

    Start-Sleep -Seconds 2
    Write-Info "后端服务已启动 http://localhost:$BackendPort"
}

function Start-Frontend {
    Write-Info "启动前端服务..."
    Stop-Port $FrontendPort

    if (-not (Test-Path (Join-Path $FrontendDir "node_modules"))) {
        Write-Info "首次运行，安装前端依赖..."
        Push-Location $FrontendDir
        npm install
        Pop-Location
    }

    Push-Location $FrontendDir
    Start-Process -FilePath "npm" -ArgumentList "run", "dev" -WindowStyle Normal
    Pop-Location

    Start-Sleep -Seconds 2
    Write-Info "前端服务已启动 http://localhost:$FrontendPort"
}

$target = if ($args.Count -gt 0) { $args[0] } else { "all" }

switch ($target) {
    "backend"  { Start-Backend }
    "frontend" { Start-Frontend }
    "all" {
        Start-Backend
        Start-Frontend
        Write-Host ""
        Write-Info "========================================="
        Write-Info "  QuarkManager 服务已启动"
        Write-Info "  后端 API:  http://localhost:$BackendPort"
        Write-Info "  前端页面:  http://localhost:$FrontendPort"
        Write-Info "  API 文档:  http://localhost:$BackendPort/docs"
        Write-Info "========================================="
        Write-Host ""
        Write-Info "关闭此窗口不会停止服务，请使用 .\stop.ps1 停止服务"
    }
    default {
        Write-Host "用法: .\start.ps1 {all|backend|frontend}"
        Write-Host "  all      - 启动前后端服务 (默认)"
        Write-Host "  backend  - 仅启动后端服务"
        Write-Host "  frontend - 仅启动前端服务"
        exit 1
    }
}
