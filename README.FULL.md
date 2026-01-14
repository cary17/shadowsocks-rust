# Shadowsocks-Rust Docker 镜像

自动构建的 Shadowsocks-Rust 多平台 Docker 镜像，支持多种变体和配置选项。

## 镜像变体

### 1. Server (纯服务端) - 默认
最小化的服务端镜像，仅包含 `ssserver`。

**标签示例：**
- `ghcr.io/cary17/shadowsocks-rust:latest`
- `ghcr.io/cary17/shadowsocks-rust:v1.x.x`
- `ghcr.io/cary17/shadowsocks-rust:latest-debian`
- `ghcr.io/cary17/shadowsocks-rust:latest-alpine`

### 2. Server-Manager (服务端+管理器)
包含 `ssserver` 和 `ssmanager`，适合需要管理多个服务器的场景。

**标签示例：**
- `ghcr.io/cary17/shadowsocks-rust:latest-server-manager-debian`
- `ghcr.io/cary17/shadowsocks-rust:v1.x.x-server-manager-alpine`

### 3. Client (纯客户端)
仅包含 `sslocal`，用于客户端场景。

**标签示例：**
- `ghcr.io/cary17/shadowsocks-rust:latest-client-debian`
- `ghcr.io/cary17/shadowsocks-rust:v1.x.x-client-alpine`

### 4. All (完整版)
包含 `sslocal`、`ssserver` 和 `ssmanager`，适合开发和测试。

**标签示例：**
- `ghcr.io/cary17/shadowsocks-rust:latest-all-debian`
- `ghcr.io/cary17/shadowsocks-rust:v1.x.x-all-alpine`

## 支持的平台

- **Debian 镜像**: `linux/amd64`, `linux/arm64`, `linux/arm/v7`
- **Alpine 镜像**: `linux/amd64`, `linux/arm64`, `linux/arm/v7`, `linux/386`

## 快速开始

### 使用环境变量配置（单服务器）

```bash
docker run -d \
  -p 34995:34995 \
  -e SS_SERVER_PORT=34995 \
  -e SS_PASSWORD="HOSWV90Z2QCFGb6hxFFbJQ==" \
  -e SS_METHOD="2022-blake3-aes-128-gcm" \
  -e SS_OUTBOUND_BIND_INTERFACE="eth0" \
  ghcr.io/cary17/shadowsocks-rust:latest
```

### 使用配置文件

```bash
docker run -d \
  -p 34995:34995 \
  -v /path/to/config.json:/etc/ss-rust/config.json:ro \
  ghcr.io/cary17/shadowsocks-rust:latest
```

### 多服务器配置

```bash
docker run -d \
  -p 34995:34995 \
  -p 38115:38115 \
  -e SS_SERVER_PORT_1=34995 \
  -e SS_PASSWORD_1="HOSWV90Z2QCFGb6hxFFbJQ==" \
  -e SS_METHOD_1="2022-blake3-aes-128-gcm" \
  -e SS_OUTBOUND_BIND_INTERFACE_1="eth0" \
  -e SS_SERVER_PORT_2=38115 \
  -e SS_PASSWORD_2="+jV8HlnpZ3gYi3UpfWxO3g==" \
  -e SS_METHOD_2="2022-blake3-aes-128-gcm" \
  -e SS_OUTBOUND_BIND_ADDR_2="11.22.33.44" \
  -e SS_OUTBOUND_FWMARK_2=255 \
  -e SS_OUTBOUND_BIND_INTERFACE_2="wg0" \
  ghcr.io/cary17/shadowsocks-rust:latest
```

## 环境变量说明

### 基础配置（必需）

| 变量 | 说明 | 示例 |
|------|------|------|
| `SS_SERVER_PORT` | 服务器端口 | `34995` |
| `SS_PASSWORD` | 密码 | `HOSWV90Z2QCFGb6hxFFbJQ==` |
| `SS_METHOD` | 加密方法 | `2022-blake3-aes-128-gcm` |

### 可选配置

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `SS_SERVER` | `::` | 监听地址 |
| `SS_DISABLED` | `false` | 是否禁用 |
| `SS_TIMEOUT` | `7200` | 超时时间(秒) |
| `SS_TCP_WEIGHT` | `1.0` | TCP 权重 |
| `SS_UDP_WEIGHT` | `1.0` | UDP 权重 |
| `SS_MODE` | `tcp_and_udp` | 运行模式 |
| `SS_DNS` | - | DNS 服务器 |
| `SS_IPV6_FIRST` | `false` | IPv6 优先 |
| `SS_IPV6_ONLY` | `false` | 仅 IPv6 |

### 出站网络配置（新增）

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `SS_OUTBOUND_BIND_INTERFACE` | - | 绑定网络接口 |
| `SS_OUTBOUND_BIND_ADDR` | - | 绑定 IP 地址 |
| `SS_OUTBOUND_FWMARK` | - | Firewall Mark |
| `SS_OUTBOUND_UDP_ALLOW_FRAGMENTATION` | `false` | 允许 UDP 分片 |

### 多服务器配置

在变量名后添加 `_N` 后缀（N 为数字 1, 2, 3...）：

```bash
SS_SERVER_PORT_1=34995
SS_PASSWORD_1="password1"
SS_METHOD_1="2022-blake3-aes-128-gcm"

SS_SERVER_PORT_2=38115
SS_PASSWORD_2="password2"
SS_METHOD_2="2022-blake3-aes-128-gcm"
SS_OUTBOUND_BIND_ADDR_2="11.22.33.44"
```

## Docker Compose 示例

### 单服务器

```yaml
version: '3.8'

services:
  shadowsocks:
    image: ghcr.io/cary17/shadowsocks-rust:latest
    container_name: ss-server
    restart: unless-stopped
    ports:
      - "34995:34995"
    environment:
      - SS_SERVER_PORT=34995
      - SS_PASSWORD=HOSWV90Z2QCFGb6hxFFbJQ==
      - SS_METHOD=2022-blake3-aes-128-gcm
      - SS_OUTBOUND_BIND_INTERFACE=eth0
      - SS_DNS=8.8.8.8
```

### 多服务器（WireGuard 场景）

```yaml
version: '3.8'

services:
  shadowsocks:
    image: ghcr.io/cary17/shadowsocks-rust:latest
    container_name: ss-server-multi
    restart: unless-stopped
    network_mode: host
    cap_add:
      - NET_ADMIN
    environment:
      # 服务器 1 - 直连
      - SS_SERVER_PORT_1=34995
      - SS_PASSWORD_1=HOSWV90Z2QCFGb6hxFFbJQ==
      - SS_METHOD_1=2022-blake3-aes-128-gcm
      - SS_OUTBOUND_BIND_INTERFACE_1=eth0
      
      # 服务器 2 - 通过 WireGuard
      - SS_SERVER_PORT_2=38115
      - SS_PASSWORD_2=+jV8HlnpZ3gYi3UpfWxO3g==
      - SS_METHOD_2=2022-blake3-aes-128-gcm
      - SS_OUTBOUND_BIND_ADDR_2=11.22.33.44
      - SS_OUTBOUND_FWMARK_2=255
      - SS_OUTBOUND_BIND_INTERFACE_2=wg0
      - SS_OUTBOUND_UDP_ALLOW_FRAGMENTATION_2=false
      
      # 全局配置
      - SS_MODE=tcp_and_udp
      - SS_DNS=8.8.8.8
```

### 客户端模式

```yaml
version: '3.8'

services:
  shadowsocks-client:
    image: ghcr.io/cary17/shadowsocks-rust:latest-client-alpine
    container_name: ss-client
    restart: unless-stopped
    ports:
      - "1080:1080"
    volumes:
      - ./client-config.json:/etc/ss-rust/config.json:ro
    command: ["sslocal", "-c", "/etc/ss-rust/config.json"]
```

## 配置文件示例

完整的 `config.json` 示例：

```json
{
  "servers": [
    {
      "disabled": false,
      "server": "::",
      "server_port": 34995,
      "password": "HOSWV90Z2QCFGb6hxFFbJQ==",
      "method": "2022-blake3-aes-128-gcm",
      "timeout": 7200,
      "tcp_weight": 1.0,
      "udp_weight": 1.0,
      "outbound_bind_interface": "eth0",
      "outbound_udp_allow_fragmentation": false
    },
    {
      "disabled": false,
      "server": "::",
      "server_port": 38115,
      "password": "+jV8HlnpZ3gYi3UpfWxO3g==",
      "method": "2022-blake3-aes-128-gcm",
      "timeout": 7200,
      "tcp_weight": 1.0,
      "udp_weight": 1.0,
      "outbound_bind_addr": "11.22.33.44",
      "outbound_fwmark": 255,
      "outbound_bind_interface": "wg0",
      "outbound_udp_allow_fragmentation": false
    }
  ],
  "mode": "tcp_and_udp",
  "dns": "8.8.8.8",
  "ipv6_first": false,
  "ipv6_only": false
}
```

## 镜像体积对比

| 变体 | Debian (约) | Alpine (约) |
|------|-------------|-------------|
| server | ~80 MB | ~15 MB |
| server-manager | ~85 MB | ~17 MB |
| client | ~80 MB | ~15 MB |
| all | ~90 MB | ~19 MB |

*实际体积因架构和版本而异*

## 自动构建

镜像每小时自动检查上游新版本并构建：
- 定时任务：每小时整点运行
- 手动触发：GitHub Actions workflow_dispatch
- 版本检测：自动对比 GHCR 和上游版本

## 许可证

本项目采用与 shadowsocks-rust 相同的许可证。
