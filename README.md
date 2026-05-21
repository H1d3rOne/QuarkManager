<div align="center">
  <img src="frontend/public/favicon.svg" alt="QuarkManager Logo" width="128" height="128">
  
  <h1>QuarkManager</h1>
  
  <p><strong>夸克网盘管理器</strong></p>
  
  <p>一个现代化的夸克网盘 Web 管理系统，支持多种登录方式和完整的文件管理功能</p>
  
  <p>
    <a href="#功能特性">功能特性</a> •
    <a href="#快速开始">快速开始</a> •
    <a href="#api-接口">API 接口</a> •
    <a href="#许可证">许可证</a>
  </p>
  
  <p>
    <img src="https://img.shields.io/badge/Python-3.8+-blue.svg" alt="Python">
    <img src="https://img.shields.io/badge/Node.js-16+-green.svg" alt="Node.js">
    <img src="https://img.shields.io/badge/Vue-3-brightgreen.svg" alt="Vue 3">
    <img src="https://img.shields.io/badge/FastAPI-0.100+-teal.svg" alt="FastAPI">
    <img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="License">
  </p>
</div>

---
若只想使用下载功能，也可以直接使用油猴脚本，详情查看这个项目：[夸克网盘下载助手](https://github.com/H1d3rOne/QuarkDownloader)

## ✨ 功能特性

### 🔐 登录方式
- 📱 **扫码登录** - 通过二维码扫描快速登录
- 🍪 **Cookie 登录** - 手动输入 Cookie 登录

### 📁 文件管理
- 📂 文件列表浏览
- ➕ 创建文件夹
- ✏️ 文件/文件夹重命名
- 📤 文件/文件夹移动
- 🗑️ 文件/文件夹删除
- 🔍 文件搜索
- ⬆️ 文件上传

### ⬇️ 下载功能

#### 普通下载
- 📄 **单文件下载** - 获取下载链接或发送到 Motrix
- 📁 **文件夹下载** - 递归下载整个文件夹（需要 Motrix）

#### 🚀 Motrix 加速下载
集成 [Motrix](https://motrix.app/) 下载管理器，实现高速下载：
- ✅ 自动检测 Motrix RPC 服务状态
- ✅ RPC 开启时自动发送下载任务到 Motrix
- ✅ RPC 未开启时返回下载链接供浏览器下载
- ✅ 支持文件夹递归下载，自动创建目录结构

<details>
<summary><b>📖 Motrix 配置步骤</b></summary>

1. **下载安装 Motrix**
   - 官网下载: https://motrix.app/
   - macOS: 下载 `.dmg` 文件安装
   - Windows: 下载 `.exe` 安装包
   - Linux: 下载 `.AppImage` 或 `.deb` 包

2. **开启 RPC 服务**
   - 打开 Motrix 应用
   - 点击右上角「齿轮」图标进入「偏好设置」
   - 选择「进阶设置」标签页
   - 找到「RPC 服务」区域：
     - ✅ 勾选「开启 RPC 服务」
     - RPC 主机: `127.0.0.1`（默认）
     - RPC 端口: `16800`（默认）
     - RPC 密钥: 留空即可
   - 点击「保存并应用」

3. **验证 RPC 服务**
   - 确保 Motrix 保持运行状态
   - 浏览器访问: http://127.0.0.1:16800/jsonrpc
   - 如果返回 `{"jsonrpc":"2.0"...}` 说明 RPC 服务正常

4. **下载目录设置**
   - 在「基础设置」中可以修改默认下载目录
   - 系统默认下载目录:
     - macOS: `~/Downloads`
     - Windows: `C:\Users\<用户名>\Downloads`
     - Linux: `~/Downloads`

**常见问题：**
- 下载任务未发送到 Motrix: 检查 RPC 服务是否开启，端口是否正确
- 下载速度慢: 在 Motrix「进阶设置」中调整「同时下载任务数」和「连接数」
- RPC 连接失败: 检查防火墙是否阻止了 16800 端口

</details>

### 🔗 分享功能

#### 创建分享
- 🔗 创建分享链接
- 🔑 设置提取码（可选）
- ⏰ 设置有效期

#### 分享链接下载
直接下载分享链接中的文件，无需转存到网盘：
- ✅ 支持单文件和文件夹下载
- ✅ 支持递归下载文件夹内所有内容
- ✅ 需要开启 Motrix RPC 服务

#### 下载模式
| 模式 | 说明 |
|------|------|
| 📥 **保存下载 (keep)** | 转存到网盘后下载，文件保留在「来自：分享」文件夹中 |
| 🧹 **无痕下载 (clean)** | 转存后下载，下载完成自动删除转存的文件，不占用网盘空间 |

---

## 🏗️ 项目结构

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

---

## 🚀 快速开始

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

| 服务 | 地址 |
|------|------|
| 🌐 前端界面 | http://localhost:8000 |
| ⚙️ 后端 API | http://localhost:3000 |
| 📖 API 文档 | http://localhost:3000/docs |

---

## 📡 API 接口

### 认证

| 方法 | 路径 | 说明 |
|------|------|------|
| `POST` | `/api/v1/auth/qrcode` | 获取登录二维码 |
| `GET` | `/api/v1/auth/qrcode/status` | 检查扫码状态 |
| `POST` | `/api/v1/auth/cookie` | Cookie 登录 |
| `GET` | `/api/v1/auth/status` | 检查登录状态 |
| `POST` | `/api/v1/auth/logout` | 登出 |

### 文件管理

| 方法 | 路径 | 说明 |
|------|------|------|
| `GET` | `/api/v1/files/list` | 获取文件列表 |
| `POST` | `/api/v1/files/folder` | 创建文件夹 |
| `PUT` | `/api/v1/files/rename` | 重命名 |
| `POST` | `/api/v1/files/move` | 移动文件 |
| `DELETE` | `/api/v1/files/delete` | 删除文件 |
| `GET` | `/api/v1/files/search` | 搜索文件 |
| `GET` | `/api/v1/files/download/{file_id}` | 下载文件 |
| `GET` | `/api/v1/files/download-folder/{folder_id}` | 下载文件夹 |
| `POST` | `/api/v1/files/upload` | 上传文件 |

### 分享管理

| 方法 | 路径 | 说明 |
|------|------|------|
| `POST` | `/api/v1/files/share` | 创建分享链接 |
| `GET` | `/api/v1/files/shares` | 获取我的分享列表 |
| `DELETE` | `/api/v1/files/share/{share_id}` | 删除分享 |
| `GET` | `/api/v1/files/share-info` | 获取分享链接信息 |
| `POST` | `/api/v1/files/transfer-share` | 转存分享文件 |
| `POST` | `/api/v1/files/download-share` | 下载分享文件（支持保存/无痕模式） |

---

## 📄 许可证

本项目基于 [MIT License](LICENSE) 开源。  
欢迎来[linux.do](https://linux.do/)社区交流、分享和反馈。

---

<div align="center">
  <p>Made with ❤️ by <a href="https://github.com/H1d3rOne">H1d3rOne</a></p>
</div>
