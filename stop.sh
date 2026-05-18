#!/bin/bash

BACKEND_PORT=3000
FRONTEND_PORT=8000

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }

stop_port() {
    local pids
    pids=$(lsof -ti:"$1" 2>/dev/null)
    if [ -n "$pids" ]; then
        kill -9 $pids 2>/dev/null
        log_info "已停止端口 $1 上的服务 (PID: $pids)"
    else
        log_warn "端口 $1 没有运行中的服务"
    fi
}

case "${1:-all}" in
    backend)
        stop_port $BACKEND_PORT
        ;;
    frontend)
        stop_port $FRONTEND_PORT
        ;;
    all)
        stop_port $BACKEND_PORT
        stop_port $FRONTEND_PORT
        log_info "所有服务已停止"
        ;;
    *)
        echo "用法: $0 {all|backend|frontend}"
        echo "  all      - 停止前后端服务 (默认)"
        echo "  backend  - 仅停止后端服务"
        echo "  frontend - 仅停止前端服务"
        exit 1
        ;;
esac
