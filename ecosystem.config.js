module.exports = {
  apps: [
    {
      name: "Redis",
      script: "/usr/bin/redis-server",
      args: "--protected-mode no --daemonize no",
      autorestart: true,
      watch: false
    },
    {
      name: "Yunzai",
      cwd: "/Yunzai", 
      script: "app.js",
      interpreter: "node",
      autorestart: true,
      min_uptime: "5s",
      max_restarts: 10,
      env: {
        NODE_ENV: "production",
        PUPPETEER_EXECUTABLE_PATH: "/usr/bin/chromium",
        PUPPETEER_SKIP_CHROMIUM_DOWNLOAD: "true"
      }
    },
    {
      name: "Tunnel",
      script: "cloudflared",
      args: "tunnel --no-autoupdate run --token " + (process.env.TUNNEL_TOKEN || ""),
      autorestart: true,
      watch: false,
      restart_delay: 5000
    }
  ]
};