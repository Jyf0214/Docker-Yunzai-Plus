#!/bin/bash

# 定义颜色
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}=== TRSS-Yunzai Docker 初始化 (PM2版) ===${NC}"

DIR="/Yunzai"
GITEE_URL="https://gitee.com/TimeRainStarSky/Yunzai.git"
GITHUB_URL="https://github.com/TimeRainStarSky/Yunzai.git"

# --- 步骤 1: 检查并安装/更新 Yunzai ---
if [ -z "$(ls -A $DIR 2>/dev/null)" ]; then
    echo -e "${GREEN}[Init] 目录为空，开始全新安装 TRSS-Yunzai...${NC}"

    # 优先尝试 Gitee 克隆，失败则尝试 GitHub
    echo -e "${YELLOW}[Init] 正在尝试从 Gitee 克隆...${NC}"
    if git clone --depth 1 $GITEE_URL $DIR; then
        echo -e "${GREEN}[Init] Gitee 克隆成功。${NC}"
    else
        echo -e "${RED}[Init] Gitee 连接失败，转为从 GitHub 克隆...${NC}"
        git clone --depth 1 $GITHUB_URL $DIR
    fi
    
    # 克隆常用插件
    echo -e "${GREEN}[Init] 正在克隆常用插件...${NC}"
    mkdir -p $DIR/plugins
    git clone --depth 1 https://gitee.com/yoimiya-kokomi/miao-plugin $DIR/plugins/miao-plugin
    git clone --depth 1 https://gitee.com/TimeRainStarSky/Yunzai-genshin.git $DIR/plugins/genshin
    git clone --depth 1 https://gitee.com/guoba-yunzai/guoba-plugin.git $DIR/plugins/Guoba-Plugin

    # 安装依赖
    cd $DIR
    echo -e "${GREEN}[Init] 安装 Node.js 依赖 (pnpm)...${NC}"
    pnpm config set registry https://registry.npmmirror.com
    pnpm install -P

    echo -e "${GREEN}[Init] 安装 Python 依赖 (yt-dlp)...${NC}"
    pip3 install yt-dlp -i https://pypi.tuna.tsinghua.edu.cn/simple

else
    echo -e "${GREEN}[Init] 检测到数据目录不为空，开始检查远程连接...${NC}"
    cd $DIR
    
    # 检查是否为 git 仓库
    if [ -d ".git" ]; then
        echo -e "${YELLOW}[Network] 正在测试 Gitee 连通性 (超时限制 10s)...${NC}"
        
        # 使用 git ls-remote 测试 Gitee 连接
        if timeout 10 git ls-remote -h $GITEE_URL HEAD > /dev/null 2>&1; then
            echo -e "${GREEN}[Network] Gitee 连接正常。${NC}"
            echo -e "${YELLOW}[Config] 强制设置远程仓库为 Gitee...${NC}"
            git remote set-url origin $GITEE_URL
        else
            echo -e "${RED}[Network] Gitee 连接失败/超时！${NC}"
            echo -e "${YELLOW}[Config] 强制切换远程仓库为 GitHub...${NC}"
            git remote set-url origin $GITHUB_URL
        fi
        
        # 刷新远程信息并拉取更新
        echo -e "${YELLOW}[Update] 正在执行 git pull...${NC}"
        git fetch origin
        git reset --hard origin/main || git reset --hard origin/master
        git pull
        
        echo -e "${YELLOW}[Update] 正在更新依赖...${NC}"
        pnpm install -P
    else
        echo -e "${RED}[Error] 目录不为空但不是 git 仓库，跳过 git 操作。${NC}"
    fi
fi

# --- 步骤 2: 修正权限 ---
chmod 777 /tmp

# --- 步骤 3: 启动 PM2 守护进程 ---
echo -e "${GREEN}[Start] 准备就绪，移交 PM2 管理进程...${NC}"
echo -e "${YELLOW}[Info] 包含服务: Redis, Yunzai, Cloudflared${NC}"

exec pm2-runtime start /root/ecosystem.config.js