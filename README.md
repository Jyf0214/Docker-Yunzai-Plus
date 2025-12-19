# Docker-Yunzai-Plus

![Docker](https://img.shields.io/badge/Docker-Enabled-blue?logo=docker)
![License](https://img.shields.io/badge/License-GPL--3.0-green)
![Status](https://img.shields.io/badge/Status-Maintained-success)

基于 Debian 的 **TRSS-Yunzai** 高级 Docker 镜像。

这是一个**开箱即用**的“三合一”解决方案。本镜像使用 **PM2** 作为进程管理器，在一个容器内同时完美运行 **Redis**、**Yunzai-Bot** 和 **Cloudflared**（内网穿透）。

## ✨ 核心特性

*   **⚡ 全能架构**：无需单独部署 Redis 容器，内置 Redis 服务，由 PM2 自动守护。
*   **🌐 内网穿透**：集成 `cloudflared`，填入 Token 即可让 Bot 拥有公网访问能力（WebUI/WebSocket）。
*   **🛡️ 稳定守护**：使用 PM2 管理所有进程，崩溃自动重启，日志管理可视化。
*   **📦 依赖全齐**：预装 **Chromium** (Puppeteer)、**FFmpeg** (音视频)、**Python3** (yt-dlp) 及中文字体，解决截图乱码和依赖报错问题。
*   **🚀 自动初始化**：首次启动自动从 Gitee 拉取 TRSS-Yunzai 代码及常用插件（Miao-Plugin, Genshin, Guoba）。

## 🛠️ 快速开始

### 方式一：Docker CLI 运行

请确保你已经安装了 Docker。

```bash
docker run -d \
  --name trss-yunzai \
  --restart always \
  # 挂载数据目录 (宿主机:容器)
  -v $(pwd)/yunzai-data:/Yunzai \
  # (可选) Cloudflare Tunnel Token
  -e TUNNEL_TOKEN="你的CloudflareToken" \
  ghcr.io/jyf0214/docker-yunzai-plus:latest
```

### 方式二：Docker Compose (推荐)

创建 `docker-compose.yml` 文件：

```yaml
version: '3.8'

services:
  yunzai:
    image: ghcr.io/jyf0214/docker-yunzai-plus:latest
    container_name: trss-yunzai
    restart: always
    environment:
      # Cloudflare Tunnel Token (可选，不填则不启动穿透)
      - TUNNEL_TOKEN=eyJhIjoi...
    volumes:
      # 数据持久化目录
      - ./yunzai-data:/Yunzai
    # 如果你需要本地直连，可以暴露端口
    ports:
      - "2536:2536" 
```

然后运行：
```bash
docker-compose up -d
```

## ⚙️ 环境变量

| 变量名 | 描述 | 默认值 |
| :--- | :--- | :--- |
| `TUNNEL_TOKEN` | Cloudflare Zero Trust 的 Tunnel Token。填入后会自动启动内网穿透。 | 空 |
| `TZ` | 容器时区 | `Asia/Shanghai` |

## 📂 目录结构

容器内的 `/Yunzai` 目录是工作目录。首次启动时，脚本会自动检测该目录：
*   **为空**：自动执行 `git clone` 拉取代码和插件，并安装依赖。
*   **不为空**：跳过安装，直接启动。

## 🖥️ 管理与监控

本镜像集成了 PM2 的可视化监控面板。

进入容器查看状态：
```bash
docker exec -it trss-yunzai pm2 monit
```
你将看到类似以下的界面，可以实时监控 Redis、Yunzai 和 Tunnel 的运行状态及日志：

```text
┌─ Process List ──────┐  ┌─ Global Logs ────────────────────────────┐
│ Redis      Mem: │  │ Redis > Ready to accept connections      │
│ Yunzai     Mem: │  │ Yunzai > Yunzai-Bot 已启动...             │
│ Tunnel     Mem: │  │ Tunnel > Registered tunnel connection... │
└─────────────────────┘  └──────────────────────────────────────────┘
```

## 🙏 致谢

*   **Yunzai-Bot**：👑 Yunzai-Bot 开山鼻祖
*   **TRSS-Yunzai**：🤖 强大繁荣的机器人框架
*   **[loveliveao/yunzai_in_docker](https://github.com/loveliveao/yunzai_in_docker)**：提供了优秀的 Docker 化思路和依赖配置参考。

## 📝 开源协议

本项目 ([Jyf0214/Docker-Yunzai-Plus](https://github.com/Jyf0214/Docker-Yunzai-Plus)) 基于 GPL-3.0 协议开源。
This project is licensed under the **GNU General Public License v3.0**.