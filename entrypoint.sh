#!/bin/sh
set -e

# 信号处理：优雅停止子进程
trap 'kill -TERM $child 2>/dev/null; wait $child 2>/dev/null' TERM INT

# 检查是否是 shadowsocks 命令
case "$1" in
    sslocal|ssserver)
        # 检查二进制是否存在
        if ! command -v "$1" >/dev/null 2>&1; then
            echo "Error: $1 is not available in this image variant"
            echo "Current variant: ${SS_VARIANT:-unknown}"
            echo ""
            echo "Available variants:"
            echo "  - server: only ssserver"
            echo "  - client: only sslocal"
            exit 1
        fi
        
        # 如果配置文件不存在且设置了环境变量，生成配置文件
        if [ ! -f "/etc/ss-rust/config.json" ]; then
            if [ -n "${SS_SERVER_PORT}" ] && [ -n "${SS_PASSWORD}" ] && [ -n "${SS_METHOD}" ]; then
                echo "Generating configuration from environment variables"
                /usr/local/bin/generate-config.sh
                echo "Configuration generated successfully"
            else
                echo "No configuration file found and required environment variables not set"
                echo "Please provide config.json or set SS_SERVER_PORT, SS_PASSWORD, and SS_METHOD"
                exit 1
            fi
        else
            echo "Configuration file found at /etc/ss-rust/config.json"
        fi
        
        echo "Ready for start up with variant: ${SS_VARIANT:-unknown}"
        ;;
esac

# 在后台启动程序
exec "$@" &

child=$!
wait $child
