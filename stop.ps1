$ErrorActionPreference = "Stop"

$BackendPort = 3000
$FrontendPort = 8000

function Write-Info($msg) { Write-Host "[INFO] " -ForegroundColor Green -NoNewline; Write-Host $msg }

function Stop-Port($port, $name) {
    $conn = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue | Where-Object { $_.State -eq "Listen" }
    if ($conn) {
        $pid = $conn.OwningProcess
        Stop-Process -Id $pid -Force -ErrorAction SilentlyContinue
        Write-Info "已停止$name服务 (PID: $pid)"
    } else {
        Write-Info "端口 $port 没有运行中的$name服务"
    }
}

$target = if ($args.Count -gt 0) { $args[0] } else { "all" }

switch ($target) {
    "backend"  { Stop-Port $BackendPort "后端" }
    "frontend" { Stop-Port $FrontendPort "前端" }
    "all" {
        Stop-Port $BackendPort "后端"
        Stop-Port $FrontendPort "前端"
        Write-Info "所有服务已停止"
    }
    default {
        Write-Host "用法: .\stop.ps1 {all|backend|frontend}"
        Write-Host "  all      - 停止前后端服务 (默认)"
        Write-Host "  backend  - 仅停止后端服务"
        Write-Host "  frontend - 仅停止前端服务"
        exit 1
    }
}
