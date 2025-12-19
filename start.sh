#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}=== TRSS-Yunzai Docker 初始化 (PM2版) ===${NC}"

DIR="/Yunzai"

if [ -z "$(ls -A $DIR 2>/dev/null)" ]; then
    echo -e "${GREEN}[Init] 目录为空，开始全新安装 TRSS-Yunzai...${NC}"

    git clone --depth 1 https://gitee.com/TimeRainStarSky/Yunzai $DIR
    
    mkdir -p $DIR/plugins
    git clone --depth 1 https://gitee.com/yoimiya-kokomi/miao-plugin $DIR/plugins/miao-plugin
    git clone --depth 1 https://gitee.com/TimeRainStarSky/Yunzai-genshin.git $DIR/plugins/genshin
    git clone --depth 1 https://gitee.com/guoba-yunzai/guoba-plugin.git $DIR/plugins/Guoba-Plugin

    cd $DIR
    echo -e "${GREEN}[Init] 安装 Node.js 依赖 (pnpm)...${NC}"
    pnpm config set registry https://registry.npmmirror.com
    pnpm install -P

    echo -e "${GREEN}[Init] 安装 Python 依赖 (yt-dlp)...${NC}"
    pip3 install yt-dlp -i https://pypi.tuna.tsinghua.edu.cn/simple

else
    echo -e "${GREEN}[Init] 检测到数据目录不为空，跳过安装步骤。${NC}"
    echo -e "${YELLOW}[Tips] 如果需要更新，请进入容器执行 git pull 和 pnpm install${NC}"
fi

chmod 777 /tmp

echo -e "${GREEN}[Start] 准备就绪，移交 PM2 管理进程...${NC}"
echo -e "${YELLOW}[Info] 包含服务: Redis, Yunzai, Cloudflared${NC}"

exec pm2-runtime start /root/ecosystem.config.js