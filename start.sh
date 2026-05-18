#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKEND_DIR="$SCRIPT_DIR/backend"
FRONTEND_DIR="$SCRIPT_DIR/frontend"
VENV_DIR="$BACKEND_DIR/.venv"

BACKEND_PORT=3000
FRONTEND_PORT=8000

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

check_port() {
    lsof -i:"$1" -sTCP:LISTEN &>/dev/null
}

kill_port() {
    local pids
    pids=$(lsof -ti:"$1" 2>/dev/null)
    if [ -n "$pids" ]; then
        kill -9 $pids 2>/dev/null
        log_warn "已终止端口 $1 上的进程: $pids"
    fi
}

setup_venv() {
    if [ -f "$VENV_DIR/bin/activate" ]; then
        return 0
    fi

    log_info "虚拟环境不存在，正在创建..."

    if command -v uv &>/dev/null; then
        log_info "使用 uv 创建虚拟环境..."
        cd "$BACKEND_DIR" || { log_error "后端目录不存在: $BACKEND_DIR"; exit 1; }
        uv venv
        log_info "使用 uv 安装依赖..."
        uv pip install -r requirements.txt
        cd "$SCRIPT_DIR"
    elif command -v python3 &>/dev/null; then
        log_info "使用 python3 创建虚拟环境..."
        cd "$BACKEND_DIR" || { log_error "后端目录不存在: $BACKEND_DIR"; exit 1; }
        python3 -m venv .venv
        source .venv/bin/activate
        pip install -r requirements.txt
        deactivate
        cd "$SCRIPT_DIR"
    else
        log_error "未找到 uv 或 python3，请先安装"
        exit 1
    fi

    log_info "虚拟环境创建完成"
}

start_backend() {
    log_info "启动后端服务..."

    if check_port $BACKEND_PORT; then
        log_warn "端口 $BACKEND_PORT 已被占用，正在关闭..."
        kill_port $BACKEND_PORT
        sleep 1
    fi

    setup_venv

    cd "$BACKEND_DIR" || { log_error "后端目录不存在: $BACKEND_DIR"; exit 1; }
    source .venv/bin/activate
    python -m uvicorn app.main:app --host 0.0.0.0 --port $BACKEND_PORT --reload &
    BACKEND_PID=$!
    deactivate
    cd "$SCRIPT_DIR"

    sleep 2
    if check_port $BACKEND_PORT; then
        log_info "后端服务已启动 ${CYAN}http://localhost:$BACKEND_PORT${NC} (PID: $BACKEND_PID)"
    else
        log_error "后端服务启动失败，请检查日志"
    fi
}

start_frontend() {
    log_info "启动前端服务..."

    if check_port $FRONTEND_PORT; then
        log_warn "端口 $FRONTEND_PORT 已被占用，正在关闭..."
        kill_port $FRONTEND_PORT
        sleep 1
    fi

    if [ ! -d "$FRONTEND_DIR/node_modules" ]; then
        log_info "首次运行，安装前端依赖..."
        cd "$FRONTEND_DIR" || { log_error "前端目录不存在: $FRONTEND_DIR"; exit 1; }
        npm install
        cd "$SCRIPT_DIR"
    fi

    cd "$FRONTEND_DIR" || { log_error "前端目录不存在: $FRONTEND_DIR"; exit 1; }
    npm run dev &
    FRONTEND_PID=$!
    cd "$SCRIPT_DIR"

    sleep 2
    if check_port $FRONTEND_PORT; then
        log_info "前端服务已启动 ${CYAN}http://localhost:$FRONTEND_PORT${NC} (PID: $FRONTEND_PID)"
    else
        log_error "前端服务启动失败，请检查日志"
    fi
}

case "${1:-all}" in
    backend)
        start_backend
        ;;
    frontend)
        start_frontend
        ;;
    all)
        start_backend
        start_frontend
        echo ""
        log_info "========================================="
        log_info "  QuarkManager 服务已启动"
        log_info "  后端 API:  http://localhost:$BACKEND_PORT"
        log_info "  前端页面:  http://localhost:$FRONTEND_PORT"
        log_info "  API 文档:  http://localhost:$BACKEND_PORT/docs"
        log_info "========================================="
        echo ""
        log_info "按 Ctrl+C 停止所有服务"
        wait
        ;;
    *)
        echo "用法: $0 {all|backend|frontend}"
        echo "  all      - 启动前后端服务 (默认)"
        echo "  backend  - 仅启动后端服务"
        echo "  frontend - 仅启动前端服务"
        exit 1
        ;;
esac
