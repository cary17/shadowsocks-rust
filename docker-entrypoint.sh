#!/bin/sh
set -e

# 信号处理函数
_term() {
  echo "Caught SIGTERM signal, shutting down..."
  kill -TERM "$child" 2>/dev/null
  wait "$child"
  exit 0
}

_int() {
  echo "Caught SIGINT signal, shutting down..."
  kill -INT "$child" 2>/dev/null
  wait "$child"
  exit 0
}

trap _term SIGTERM
trap _int SIGINT

if [ -z "${SS_ENTRYPOINT_QUIET_LOGS:-}" ]; then
    exec 3>&1
else
    exec 3>/dev/null
fi

# 检查是否是 shadowsocks 命令
if [ "$1" = "sslocal" ] || [ "$1" = "ssserver" ] || [ "$1" = "ssmanager" ] || [ "$1" = "ssservice" ]; then
    # 如果配置文件不存在且设置了环境变量，生成配置文件
    if [ ! -f "/etc/shadowsocks-rust/config.json" ]; then
        if [ -n "${SS_SERVER_PORT}" ] && [ -n "${SS_PASSWORD}" ] && [ -n "${SS_METHOD}" ]; then
            echo >&3 "$0: Generating configuration from environment variables"
            /usr/local/bin/generate-config.sh
            echo >&3 "$0: Configuration generated successfully"
        else
            echo >&3 "$0: No configuration file found and required environment variables not set"
            echo >&3 "$0: Please provide config.json or set SS_SERVER_PORT, SS_PASSWORD, and SS_METHOD"
            exit 1
        fi
    else
        echo >&3 "$0: Configuration file found at /etc/shadowsocks-rust/config.json"
    fi
    
    echo >&3 "$0: Ready for start up"
fi

# 在后台启动程序
exec "$@" &

child=$!
wait "$child"
