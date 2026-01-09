# Shadowsocks-Rust Docker Image

自动构建 [shadowsocks-rust](https://github.com/shadowsocks/shadowsocks-rust) 的多架构 Docker 镜像。

## 特性

- 🕐 每小时自动检查新版本并构建
- 🏗️ 支持多架构：`amd64`、`arm64`、`armv7`、`386`
- 🐧 提供 Debian 和 Alpine 两种基础镜像
- 📦 镜像同时发布到 GHCR 和 Docker Hub
- ⚙️ 支持配置文件和环境变量两种配置方式
- 🔄 优雅处理 SIGTERM 和 SIGINT 信号

## 支持的镜像标签

### 按版本和基础镜像
- `latest` - 最新版本 (Alpine)
- `latest-alpine` - 最新版本 Alpine
- `latest-debian` - 最新版本 Debian
- `1.24.0` - 指定版本 (Alpine)
- `1.24.0-alpine` - 指定版本 Alpine
- `1.24.0-debian` - 指定版本 Debian

### 按架构
- `latest-alpine-x86_64`
- `latest-alpine-aarch64`
- `latest-alpine-arm`
- `latest-alpine-i686`
- `latest-debian-x86_64`
- `latest-debian-aarch64`
- `latest-debian-arm`

## 快速开始

### 使用配置文件

```bash
docker run -d \
  --name shadowsocks \
  -p 8388:8388/tcp \
  -p 8388:8388/udp \
  -v /path/to/config.json:/etc/shadowsocks-rust/config.json:ro \
  --restart unless-stopped \
  ghcr.io/your-username/shadowsocks-rust:latest
```

配置文件示例 (`config.json`):
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
  "mode": "tcp_and_udp",
  "ipv6_first": false,
  "ipv6_only": false
}
```

### 使用环境变量 (单服务器)

```bash
docker run -d \
  --name shadowsocks \
  -p 8388:8388/tcp \
  -p 8388:8388/udp \
  -e SS_SERVER_PORT=8388 \
  -e SS_PASSWORD="your-password" \
  -e SS_METHOD="2022-blake3-aes-128-gcm" \
  -e SS_MODE="tcp_and_udp" \
  --restart unless-stopped \
  ghcr.io/your-username/shadowsocks-rust:latest
```

### 使用环境变量 (多服务器)

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
  --restart unless-stopped \
  ghcr.io/your-username/shadowsocks-rust:latest
```

## Docker Compose 示例

### 单服务器配置

```yaml
version: '3.8'

services:
  shadowsocks:
    image: ghcr.io/your-username/shadowsocks-rust:latest
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
    restart: unless-stopped
```

### 使用配置文件

```yaml
version: '3.8'

services:
  shadowsocks:
    image: ghcr.io/your-username/shadowsocks-rust:latest
    container_name: shadowsocks
    ports:
      - "8388:8388/tcp"
      - "8388:8388/udp"
    volumes:
      - ./config.json:/etc/shadowsocks-rust/config.json:ro
    restart: unless-stopped
```

### 多服务器配置

```yaml
version: '3.8'

services:
  shadowsocks:
    image: ghcr.io/your-username/shadowsocks-rust:latest
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
    restart: unless-stopped
```

## 环境变量说明

### 单服务器环境变量

| 变量名 | 必填 | 默认值 | 说明 |
|--------|------|--------|------|
| `SS_SERVER_PORT` | ✅ | - | 服务器端口 |
| `SS_PASSWORD` | ✅ | - | 密码 |
| `SS_METHOD` | ✅ | - | 加密方法 |
| `SS_SERVER` | ❌ | `::` | 监听地址 |
| `SS_MODE` | ❌ | `tcp_and_udp` | 模式 (tcp_only/udp_only/tcp_and_udp) |
| `SS_DISABLED` | ❌ | `false` | 是否禁用 |
| `SS_TIMEOUT` | ❌ | `7200` | 超时时间(秒) |
| `SS_TCP_WEIGHT` | ❌ | `1.0` | TCP 权重 |
| `SS_UDP_WEIGHT` | ❌ | `1.0` | UDP 权重 |
| `SS_OUTBOUND_BIND_INTERFACE` | ❌ | - | 出站绑定接口 |
| `SS_DNS` | ❌ | - | DNS 服务器 |
| `SS_IPV6_FIRST` | ❌ | `false` | 优先使用 IPv6 |
| `SS_IPV6_ONLY` | ❌ | `false` | 仅使用 IPv6 |

### 多服务器环境变量

对于多服务器配置,在变量名后添加 `_N` (N 为数字索引,从 1 开始):

- `SS_SERVER_PORT_1`, `SS_SERVER_PORT_2`, ...
- `SS_PASSWORD_1`, `SS_PASSWORD_2`, ...
- `SS_METHOD_1`, `SS_METHOD_2`, ...
- `SS_OUTBOUND_BIND_INTERFACE_1`, `SS_OUTBOUND_BIND_INTERFACE_2`, ...
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

传统加密方法：
- `aes-128-gcm`
- `aes-256-gcm`
- `chacha20-ietf-poly1305`

## 运行其他命令

### sslocal (客户端)
```bash
docker run -d \
  --name ss-local \
  -p 1080:1080 \
  -v /path/to/config.json:/etc/shadowsocks-rust/config.json:ro \
  ghcr.io/your-username/shadowsocks-rust:latest \
  sslocal -c /etc/shadowsocks-rust/config.json
```

### ssmanager (管理器)
```bash
docker run -d \
  --name ss-manager \
  -p 8839:8839 \
  -v /path/to/config.json:/etc/shadowsocks-rust/config.json:ro \
  ghcr.io/your-username/shadowsocks-rust:latest \
  ssmanager -c /etc/shadowsocks-rust/config.json
```

## 构建自己的镜像

1. Fork 此仓库
2. 在仓库的 Settings -> Secrets and variables -> Actions 中添加：
   - `DOCKERHUB_USERNAME`: Docker Hub 用户名
   - `DOCKERHUB_TOKEN`: Docker Hub 访问令牌
3. 工作流将自动运行，每小时检查新版本

手动触发构建：
1. 前往 Actions 标签页
2. 选择 "Build and Push Docker Images" 工作流
3. 点击 "Run workflow"
4. 可选择 Debian 版本 (默认为 12)

## 镜像大小对比

| 基础镜像 | 架构 | 大小（约） |
|---------|------|-----------|
| Alpine | amd64 | ~15MB |
| Alpine | arm64 | ~14MB |
| Alpine | armv7 | ~13MB |
| Alpine | 386 | ~14MB |
| Debian | amd64 | ~45MB |
| Debian | arm64 | ~43MB |
| Debian | armv7 | ~41MB |

## 许可证

本项目使用 MIT 许可证。Shadowsocks-Rust 使用其自己的许可证。

## 相关链接

- [Shadowsocks-Rust GitHub](https://github.com/shadowsocks/shadowsocks-rust)
- [Shadowsocks-Rust 文档](https://github.com/shadowsocks/shadowsocks-rust/blob/master/README.md)
