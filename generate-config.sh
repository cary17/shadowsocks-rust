#!/bin/sh
# 从环境变量生成 shadowsocks-rust 配置文件

CONFIG_FILE="/etc/shadowsocks-rust/config.json"

# 获取所有 SS_SERVER_PORT_* 环境变量
get_server_indices() {
    env | grep '^SS_SERVER_PORT_' | sed 's/SS_SERVER_PORT_\([0-9]*\)=.*/\1/' | sort -n
}

# 构建服务器配置
build_servers() {
    INDICES=$(get_server_indices)
    
    if [ -z "$INDICES" ]; then
        # 单服务器配置（无索引）
        if [ -z "${SS_SERVER_PORT}" ] || [ -z "${SS_PASSWORD}" ] || [ -z "${SS_METHOD}" ]; then
            echo "Error: SS_SERVER_PORT, SS_PASSWORD, and SS_METHOD are required"
            exit 1
        fi
        
        cat << EOF
    {
      "disabled": ${SS_DISABLED:-false},
      "server": "${SS_SERVER:-::}",
      "server_port": ${SS_SERVER_PORT},
      "password": "${SS_PASSWORD}",
      "method": "${SS_METHOD}",
      "timeout": ${SS_TIMEOUT:-7200},
      "tcp_weight": ${SS_TCP_WEIGHT:-1.0},
      "udp_weight": ${SS_UDP_WEIGHT:-1.0}$(if [ -n "${SS_OUTBOUND_BIND_INTERFACE}" ]; then echo ",
      \"outbound_bind_interface\": \"${SS_OUTBOUND_BIND_INTERFACE}\""; fi)
    }
EOF
    else
        # 多服务器配置
        FIRST=1
        for i in $INDICES; do
            eval PORT=\$SS_SERVER_PORT_$i
            eval PASSWORD=\$SS_PASSWORD_$i
            eval METHOD=\$SS_METHOD_$i
            
            if [ -z "$PORT" ] || [ -z "$PASSWORD" ] || [ -z "$METHOD" ]; then
                echo "Error: SS_SERVER_PORT_$i, SS_PASSWORD_$i, and SS_METHOD_$i are required"
                exit 1
            fi
            
            eval DISABLED=\$SS_DISABLED_$i
            eval SERVER=\$SS_SERVER_$i
            eval TIMEOUT=\$SS_TIMEOUT_$i
            eval TCP_WEIGHT=\$SS_TCP_WEIGHT_$i
            eval UDP_WEIGHT=\$SS_UDP_WEIGHT_$i
            eval OUTBOUND_BIND_INTERFACE=\$SS_OUTBOUND_BIND_INTERFACE_$i
            
            if [ $FIRST -eq 0 ]; then
                echo ","
            fi
            FIRST=0
            
            cat << EOF
    {
      "disabled": ${DISABLED:-false},
      "server": "${SERVER:-::}",
      "server_port": ${PORT},
      "password": "${PASSWORD}",
      "method": "${METHOD}",
      "timeout": ${TIMEOUT:-7200},
      "tcp_weight": ${TCP_WEIGHT:-1.0},
      "udp_weight": ${UDP_WEIGHT:-1.0}$(if [ -n "$OUTBOUND_BIND_INTERFACE" ]; then echo ",
      \"outbound_bind_interface\": \"$OUTBOUND_BIND_INTERFACE\""; fi)
    }
EOF
        done
    fi
}

# 生成配置文件
cat > "$CONFIG_FILE" << EOF
{
  "servers": [
$(build_servers)
  ],
  "mode": "${SS_MODE:-tcp_and_udp}"$(if [ -n "${SS_DNS}" ]; then echo ",
  \"dns\": \"${SS_DNS}\""; fi),
  "ipv6_first": ${SS_IPV6_FIRST:-false},
  "ipv6_only": ${SS_IPV6_ONLY:-false}
}
EOF

echo "Configuration file generated at $CONFIG_FILE"
