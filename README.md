# QuarkManager - 夸克网盘管理器

一个现代化的夸克网盘 Web 管理系统，支持多种登录方式和完整的文件管理功能。

## 技术栈

### 后端
- **FastAPI** - 高性能 Web 框架
- **Uvicorn** - ASGI 服务器
- **uv** - Python 包管理器

### 前端
- **Vue 3** - 前端框架
- **TypeScript** - 类型安全
- **Vite** - 构建工具

## 功能特性

### 登录方式
- 扫码登录 - 通过二维码扫描快速登录
- Cookie 登录 - 手动输入 Cookie 登录

### 文件管理
- 文件列表浏览
- 创建文件夹
- 文件/文件夹重命名
- 文件/文件夹移动
- 文件/文件夹删除
- 文件搜索
- 文件下载

## 项目结构

```
QuarkManager/
├── backend/           # 后端服务 (端口: 3000)
│   ├── app/
│   │   ├── api/v1/   # API 路由
│   │   ├── core/     # 核心配置
│   │   ├── schemas/  # Pydantic 模式
│   │   ├── services/ # 业务服务
│   │   └── main.py   # 入口文件
│   └── requirements.txt
├── frontend/          # 前端应用 (端口: 8000)
│   ├── src/
│   │   ├── api/      # API 接口
│   │   ├── views/    # 页面组件
│   │   ├── router/   # 路由
│   │   └── stores/   # 状态管理
│   └── vite.config.ts
├── quark_client/     # Quark API 客户端库
│   ├── auth/         # 认证模块
│   ├── cli/          # 命令行工具
│   ├── services/     # 服务层
│   └── config/       # 配置存储目录
├── start.sh          # macOS/Linux 启动脚本
├── start.bat         # Windows 启动脚本
├── start.ps1         # Windows PowerShell 启动脚本
├── stop.sh           # macOS/Linux 停止脚本
├── stop.bat          # Windows 停止脚本
└── stop.ps1          # Windows PowerShell 停止脚本
```

## 快速开始

### 环境要求
- Python 3.8+
- Node.js 16+
- uv (Python 包管理器)

### 安装 uv
```bash
# macOS/Linux
curl -LsSf https://astral.sh/uv/install.sh | sh

# Windows
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
```

### 启动服务

**macOS/Linux:**
```bash
./start.sh
```

**Windows:**
```bash
start.bat
# 或 PowerShell
.\start.ps1
```

### 停止服务

**macOS/Linux:**
```bash
./stop.sh
```

**Windows:**
```bash
stop.bat
# 或 PowerShell
.\stop.ps1
```

### 访问应用
- 前端界面: http://localhost:8000
- 后端 API: http://localhost:3000
- API 文档: http://localhost:3000/docs

## API 接口

### 认证
- `POST /api/v1/auth/qrcode` - 获取登录二维码
- `GET /api/v1/auth/qrcode/status` - 检查扫码状态
- `POST /api/v1/auth/cookie` - Cookie 登录
- `GET /api/v1/auth/status` - 检查登录状态
- `POST /api/v1/auth/logout` - 登出

### 文件管理
- `GET /api/v1/files/list` - 获取文件列表
- `POST /api/v1/files/create` - 创建文件夹
- `POST /api/v1/files/rename` - 重命名
- `POST /api/v1/files/move` - 移动文件
- `POST /api/v1/files/delete` - 删除文件
- `GET /api/v1/files/search` - 搜索文件
- `GET /api/v1/files/download` - 下载文件

## 许可证

MIT License
