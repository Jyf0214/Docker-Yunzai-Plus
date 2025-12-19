FROM debian:bullseye-slim as downloader

ARG TARGETARCH
RUN apt-get update && apt-get install -y curl

RUN url="" && \
    if [ "$TARGETARCH" = "amd64" ]; then \
        url="https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64"; \
    elif [ "$TARGETARCH" = "arm64" ]; then \
        url="https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64"; \
    else \
        echo "Unsupported architecture: $TARGETARCH"; exit 1; \
    fi && \
    curl -L $url -o /cloudflared && \
    chmod +x /cloudflared

FROM debian:bullseye-slim

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai

RUN sed -i 's@http://deb.debian.org/@http://mirrors.aliyun.com/@g' /etc/apt/sources.list && \
    sed -i 's@http://security.debian.org/@http://mirrors.aliyun.com/@g' /etc/apt/sources.list && \
    apt-get update -y && \
    apt-get install -y --no-install-recommends \
    wget xz-utils dos2unix curl gnupg git \
    fonts-wqy-microhei xfonts-utils chromium fontconfig libxss1 libgl1 \
    vim jq python3 python3-pip python3-dev \
    redis-server procps ffmpeg atomicparsley \
    ca-certificates make g++ \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN echo "zh_CN.UTF-8 UTF-8" > /etc/locale.gen && \
    apt-get update && apt-get install -y locales && \
    locale-gen zh_CN.UTF-8 && \
    update-locale LANG=zh_CN.UTF-8
ENV LANG=zh_CN.UTF-8 \
    LANGUAGE=zh_CN:zh \
    LC_ALL=zh_CN.UTF-8

RUN curl -sL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    node -v && npm -v

RUN npm --registry=https://registry.npmmirror.com install pnpm pm2 -g && \
    pnpm config set registry https://registry.npmmirror.com

COPY --from=downloader /cloudflared /usr/bin/cloudflared

COPY ecosystem.config.js /root/ecosystem.config.js
COPY start.sh /start.sh

RUN chmod +x /start.sh

ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium \
    TUNNEL_TOKEN=""

WORKDIR /Yunzai
VOLUME ["/Yunzai"]

EXPOSE 2536

CMD ["/bin/bash", "/start.sh"]