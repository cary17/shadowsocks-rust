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
        
        echo "Ready for start up with variant: ${SS_VARIANT:-unknown}"
        ;;
esac

# 在后台启动程序
exec "$@" &

child=$!
wait $child
