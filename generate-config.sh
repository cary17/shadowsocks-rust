#!/bin/sh
set -e

CONFIG_FILE="/etc/ss-rust/config.json"

# 获取所有 SS_SERVER_PORT_* 环境变量
get_server_indices() {
    env | grep '^SS_SERVER_PORT_' | sed 's/SS_SERVER_PORT_\([0-9]*\)=.*/\1/' | sort -n
}

# 构建单个服务器配置
build_server_config() {
    prefix="$1"
    idx="$2"
    
    if [ -z "$idx" ]; then
        port_var="SS_SERVER_PORT"
        pass_var="SS_PASSWORD"
        method_var="SS_METHOD"
        disabled_var="SS_DISABLED"
        server_var="SS_SERVER"
        timeout_var="SS_TIMEOUT"
        tcp_var="SS_TCP_WEIGHT"
        udp_var="SS_UDP_WEIGHT"
        bind_var="SS_OUTBOUND_BIND_INTERFACE"
    else
        port_var="SS_SERVER_PORT_$idx"
        pass_var="SS_PASSWORD_$idx"
        method_var="SS_METHOD_$idx"
        disabled_var="SS_DISABLED_$idx"
        server_var="SS_SERVER_$idx"
        timeout_var="SS_TIMEOUT_$idx"
        tcp_var="SS_TCP_WEIGHT_$idx"
        udp_var="SS_UDP_WEIGHT_$idx"
        bind_var="SS_OUTBOUND_BIND_INTERFACE_$idx"
    fi
    
    eval port=\$$port_var
    eval pass=\$$pass_var
    eval method=\$$method_var
    
    # 检查必需参数
    if [ -z "$port" ] || [ -z "$pass" ] || [ -z "$method" ]; then
        echo "Error: ${port_var}, ${pass_var}, and ${method_var} are required"
        exit 1
    fi
    
    eval disabled=\${$disabled_var:-false}
    eval server=\${$server_var:-::}
    eval timeout=\${$timeout_var:-7200}
    eval tcp_weight=\${$tcp_var:-1.0}
    eval udp_weight=\${$udp_var:-1.0}
    eval bind_interface=\$$bind_var
    
    cat << EOF
    {
      "disabled": $disabled,
      "server": "$server",
      "server_port": $port,
      "password": "$pass",
      "method": "$method",
      "timeout": $timeout,
      "tcp_weight": $tcp_weight,
      "udp_weight": $udp_weight$([ -n "$bind_interface" ] && echo ",\n      \"outbound_bind_interface\": \"$bind_interface\"")
    }
EOF
}

# 主逻辑
INDICES=$(get_server_indices)

if [ -z "$INDICES" ] && { [ -z "$SS_SERVER_PORT" ] || [ -z "$SS_PASSWORD" ] || [ -z "$SS_METHOD" ]; }; then
    echo "Error: SS_SERVER_PORT, SS_PASSWORD, and SS_METHOD are required"
    exit 1
fi

{
    echo '{'
    echo '  "servers": ['
    
    if [ -z "$INDICES" ]; then
        # 单服务器配置
        build_server_config "single" ""
    else
        # 多服务器配置
        first=1
        for idx in $INDICES; do
            if [ $first -eq 0 ]; then
                echo ","
            fi
            first=0
            build_server_config "multi" "$idx"
        done
    fi
    
    echo '  ],'
    echo "  \"mode\": \"${SS_MODE:-tcp_and_udp}\"$([ -n "$SS_DNS" ] && echo ",\n  \"dns\": \"$SS_DNS\"")"
    echo "}"
} > "$CONFIG_FILE"

echo "Configuration file generated at $CONFIG_FILE"