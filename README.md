# Shadowsocks-Rust Docker

自动构建 [shadowsocks-rust](https://github.com/shadowsocks/shadowsocks-rust) 的多架构 Docker 镜像。

> **注意**: 本镜像环境变量和配置示例均为服务器端配置。如需运行客户端，请参考[shadowsocks-rust](https://github.com/shadowsocks/shadowsocks-rust)自行准备配置文件挂载。

## 特性

- 🕐 每小时自动检查新版本并构建
- 🏗️ 支持多架构：`amd64`、`arm64`、`armv7`、`386`
- 🐧 提供 Debian 和 Alpine 两种基础镜像
- 📦 镜像同时发布到 GHCR 和 Docker Hub
- ⚙️ 服务器端支持配置文件和环境变量两种配置方式

## 支持的镜像标签

所有标签都支持多架构，Docker 会自动拉取适合你系统的架构版本。

### 标签说明

- `latest` / `latest-debian` - 最新版本 Debian (多架构: amd64, arm64, armv7)
- `latest-alpine` - 最新版本 Alpine (多架构: amd64, arm64, armv7, 386)
- `v1.24.0` / `v1.24.0-debian` - 指定版本 Debian (多架构)
- `v1.24.0-alpine` - 指定版本 Alpine (多架构)

### 支持的架构

- **Debian**: `linux/amd64`, `linux/arm64`, `linux/arm/v7`
- **Alpine**: `linux/amd64`, `linux/arm64`, `linux/arm/v7`, `linux/386`

## 快速开始

> **重要**: 以下所有配置均为 **Shadowsocks 服务器端配置**。

### 使用配置文件 (推荐)

```bash
docker run -d \
  --name shadowsocks \
  -p 8388:8388/tcp \
  -p 8388:8388/udp \
  -v /path/to/config.json:/etc/shadowsocks-rust/config.json:ro \
  --restart always \
  ghcr.io/cary17/shadowsocks-rust:latest
```

配置文件示例 (`config.json`) - **服务器端配置**:

```json
{
  "servers": [
    {
      "disabled": false,
      "server": "::",
      "server_port": 8388,
      "password": "your-password",
      "method": "2022-blake3-aes-128-gcm",
      "timeout": 7200,
      "tcp_weight": 1.0,
      "udp_weight": 1.0
    }
  ],
  #"dns": "8.8.8.8",
  "mode": "tcp_and_udp",
  "ipv6_first": false,
  "ipv6_only": false
}
```

### 使用环境变量 (单服务器) - 服务器端配置

```bash
docker run -d \
  --name shadowsocks \
  -p 8388:8388/tcp \
  -p 8388:8388/udp \
  -e SS_SERVER_PORT=8388 \
  -e SS_PASSWORD="your-password" \
  -e SS_METHOD="2022-blake3-aes-128-gcm" \
  -e SS_MODE="tcp_and_udp" \
  --restart always \
  ghcr.io/cary17/shadowsocks-rust:latest
```

### 使用环境变量 (多服务器) - 服务器端配置

```bash
docker run -d \
  --name shadowsocks \
  -p 34995:34995/tcp \
  -p 34995:34995/udp \
  -p 38115:38115/tcp \
  -p 38115:38115/udp \
  -e SS_SERVER_PORT_1=34995 \
  -e SS_PASSWORD_1="password1" \
  -e SS_METHOD_1="2022-blake3-aes-128-gcm" \
  -e SS_OUTBOUND_BIND_INTERFACE_1="eth0" \
  -e SS_SERVER_PORT_2=38115 \
  -e SS_PASSWORD_2="password2" \
  -e SS_METHOD_2="2022-blake3-aes-128-gcm" \
  -e SS_OUTBOUND_BIND_INTERFACE_2="wg0" \
  -e SS_MODE="tcp_and_udp" \
  --restart always \
  ghcr.io/cary17/shadowsocks-rust:latest
```

## Docker Compose 示例

### 单服务器配置

```yaml
version: '3.8'

services:
  shadowsocks:
    image: ghcr.io/cary17/shadowsocks-rust:latest
    container_name: shadowsocks
    ports:
      - "8388:8388/tcp"
      - "8388:8388/udp"
    environment:
      - SS_SERVER_PORT=8388
      - SS_PASSWORD=your-password
      - SS_METHOD=2022-blake3-aes-128-gcm
      - SS_MODE=tcp_and_udp
      - SS_TIMEOUT=7200
    restart: always
```

### 使用配置文件

```yaml
version: '3.8'

services:
  shadowsocks:
    image: ghcr.io/cary17/shadowsocks-rust:latest
    container_name: shadowsocks
    ports:
      - "8388:8388/tcp"
      - "8388:8388/udp"
    volumes:
      - ./config.json:/etc/shadowsocks-rust/config.json:ro
    restart: always
```

### 多服务器配置

```yaml
version: '3.8'

services:
  shadowsocks:
    image: ghcr.io/cary17/shadowsocks-rust:latest
    container_name: shadowsocks
    ports:
      - "34995:34995/tcp"
      - "34995:34995/udp"
      - "38115:38115/tcp"
      - "38115:38115/udp"
    environment:
      - SS_SERVER_PORT_1=34995
      - SS_PASSWORD_1=password1
      - SS_METHOD_1=2022-blake3-aes-128-gcm
      - SS_OUTBOUND_BIND_INTERFACE_1=eth0
      - SS_SERVER_PORT_2=38115
      - SS_PASSWORD_2=password2
      - SS_METHOD_2=2022-blake3-aes-128-gcm
      - SS_OUTBOUND_BIND_INTERFACE_2=wg0
      - SS_MODE=tcp_and_udp
      - SS_DNS=8.8.8.8,1.0.0.1
    restart: always
```

## 环境变量说明

> **注意**: 所有环境变量均为 **Shadowsocks 服务器端配置**。

### 单服务器环境变量

|变量名                         |必填|默认值          |说明                                |
|----------------------------|--|-------------|----------------------------------|
|`SS_SERVER_PORT`            |✅ |-            |服务器端口                             |
|`SS_PASSWORD`               |✅ |-            |密码                                |
|`SS_METHOD`                 |✅ |-            |加密方法                              |
|`SS_SERVER`                 |❌ |`::`         |监听地址                              |
|`SS_MODE`                   |❌ |`tcp_and_udp`|模式 (tcp_only/udp_only/tcp_and_udp)|
|`SS_DISABLED`               |❌ |`false`      |是否禁用                              |
|`SS_TIMEOUT`                |❌ |`7200`       |超时时间(秒)                           |
|`SS_TCP_WEIGHT`             |❌ |`1.0`        |TCP 权重                            |
|`SS_UDP_WEIGHT`             |❌ |`1.0`        |UDP 权重                            |
|`SS_OUTBOUND_BIND_INTERFACE`|❌ |-            |出站绑定接口                            |
|`SS_DNS`                    |❌ |-            |DNS 服务器                           |
|`SS_IPV6_FIRST`             |❌ |`false`      |优先使用 IPv6                         |
|`SS_IPV6_ONLY`              |❌ |`false`      |仅使用 IPv6                          |

### 多服务器环境变量

对于多服务器配置,在变量名后添加 `_N` (N 为数字索引,从 1 开始):

- `SS_SERVER_PORT_1`, `SS_SERVER_PORT_2`, …
- `SS_PASSWORD_1`, `SS_PASSWORD_2`, …
- `SS_METHOD_1`, `SS_METHOD_2`, …
- `SS_OUTBOUND_BIND_INTERFACE_1`, `SS_OUTBOUND_BIND_INTERFACE_2`, …
- 等等

全局配置（不带索引）:

- `SS_MODE`
- `SS_DNS`
- `SS_IPV6_FIRST`
- `SS_IPV6_ONLY`

## 支持的加密方法

推荐使用以下现代加密方法：

- `2022-blake3-aes-128-gcm`
- `2022-blake3-aes-256-gcm`
- `2022-blake3-chacha20-poly1305`
其他加密方法请查看 [shadowsocks-rust](https://github.com/shadowsocks/shadowsocks-rust) 


### sslocal (客户端)

如需运行客户端，需要准备客户端配置文件挂载。


## 📦 镜像仓库

### GHCR 
```bash
ghcr.io/cary17/shadowsocks-rust:latest
ghcr.io/cary17/shadowsocks-rust:v1.24.0
```

### Docker Hub
```bash
cary17/shadowsocks-rust:latest
cary17/shadowsocks-rust:v1.24.0
```
