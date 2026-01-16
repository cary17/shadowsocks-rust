# Shadowsocks-rust Docker

基于官方 [shadowsocks-rust](https://github.com/shadowsocks/shadowsocks-rust) 的 Docker 镜像，支持多架构、多变体自动构建。

## 镜像变体

本项目提供以下镜像变体：

### 按基础镜像分类
- **Debian**: 基于 Debian stable，体积较大但兼容性好
- **Alpine**: 基于 Alpine Linux，体积小巧

### 按功能分类
- **Server**: 仅包含 `ssserver`，用于搭建服务端
- **Client**: 仅包含 `sslocal`，用于客户端代理

## 支持的架构

- **Debian 变体**: `linux/amd64`, `linux/arm64`, `linux/arm/v7`
- **Alpine 变体**: `linux/amd64`, `linux/arm64`, `linux/arm/v7`, `linux/386`

## 镜像标签说明

标签格式：`<version>-<variant>-<base>` 或 `latest-<variant>-<base>`

### 服务端标签示例
```
ghcr.io/cary17/shadowsocks-rust:v1.17.0-server-debian
ghcr.io/cary17/shadowsocks-rust:v1.17.0-server-alpine
ghcr.io/cary17/shadowsocks-rust:latest-server-debian
ghcr.io/cary17/shadowsocks-rust:latest-server-alpine
ghcr.io/cary17/shadowsocks-rust:v1.17.0  # Debian server 简写
ghcr.io/cary17/shadowsocks-rust:latest   # Debian server 简写
```

### 客户端标签示例
```
ghcr.io/cary17/shadowsocks-rust:v1.17.0-client-debian
ghcr.io/cary17/shadowsocks-rust:v1.17.0-client-alpine
ghcr.io/cary17/shadowsocks-rust:latest-client-debian
ghcr.io/cary17/shadowsocks-rust:latest-client-alpine
```

## 快速开始

### 服务端（使用环境变量）

```bash
docker run -d \
  --name ss-rust-server \
  -p 8388:8388/tcp \
  -p 8388:8388/udp \
  -e SS_SERVER_PORT=8388 \
  -e SS_PASSWORD=your_password \
  -e SS_METHOD=aes-256-gcm \
  ghcr.io/cary17/shadowsocks-rust:latest
```

### 使用配置文件

```bash
docker run -d \
  --name ss-rust-server \
  -p 8388:8388/tcp \
  -p 8388:8388/udp \
  -v /path/to/config:/etc/ss-rust \
  ghcr.io/cary17/shadowsocks-rust:latest
```

## 环境变量说明

### 服务端环境变量

| 变量名 | 必填 | 默认值 | 说明 |
|--------|------|--------|------|
| `SS_SERVER_PORT` | 是 | - | 监听端口 |
| `SS_PASSWORD` | 是 | - | 密码 |
| `SS_METHOD` | 是 | - | 加密方法 |
| `SS_SERVER` | 否 | `::` | 监听地址 |
| `SS_TIMEOUT` | 否 | `7200` | 超时时间（秒）|
| `SS_MODE` | 否 | `tcp_and_udp` | 工作模式 |
| `SS_DNS` | 否 | - | DNS 服务器地址 |
| `SS_IPV6_FIRST` | 否 | `false` | IPv6 优先 |
| `SS_DISABLED` | 否 | `false` | 禁用此服务器 |
| `SS_TCP_WEIGHT` | 否 | `1.0` | TCP 权重 |
| `SS_UDP_WEIGHT` | 否 | `1.0` | UDP 权重 |
| `SS_OUTBOUND_BIND_INTERFACE` | 否 | - | 出站网络接口 |
| `SS_OUTBOUND_BIND_ADDR` | 否 | - | 出站绑定地址 |
| `SS_OUTBOUND_UDP_ALLOW_FRAGMENTATION` | 否 | `false` | 允许 UDP 分片 |


### 多服务器配置

支持通过环境变量配置多个服务器（仅服务端/客户端）：

```bash
docker run -d \
  --name ss-rust-server \
  -p 8388:8388/tcp \
  -p 8389:8389/tcp \
  -e SS_SERVER_PORT_1=8388 \
  -e SS_PASSWORD_1=password1 \
  -e SS_METHOD_1=aes-256-gcm \
  -e SS_SERVER_PORT_2=8389 \
  -e SS_PASSWORD_2=password2 \
  -e SS_METHOD_2=chacha20-ietf-poly1305 \
  ghcr.io/cary17/shadowsocks-rust:latest
```

## 支持的加密方法

- `aes-128-gcm`
- `aes-256-gcm`
- `chacha20-ietf-poly1305`
- `2022-blake3-aes-128-gcm`
- `2022-blake3-aes-256-gcm`
- `2022-blake3-chacha20-poly1305`

推荐使用 AEAD 加密方法或 Shadowsocks 2022 系列。

## Docker Compose 示例

### 服务端

```yaml
version: '3.8'

services:
  shadowsocks-server:
    image: ghcr.io/cary17/shadowsocks-rust:latest
    container_name: ss-server
    restart: unless-stopped
    ports:
      - "8388:8388/tcp"
      - "8388:8388/udp"
    environment:
      - SS_SERVER_PORT=8388
      - SS_PASSWORD=your_strong_password
      - SS_METHOD=aes-256-gcm
      - SS_TIMEOUT=7200
      - SS_MODE=tcp_and_udp
```


## 配置文件格式

如果使用配置文件方式，将配置文件放在 `/etc/ss-rust/config.json`。

### 服务端配置示例

```json
{
  "servers": [
    {
      "server": "::",
      "server_port": 8388,
      "password": "your_password",
      "method": "aes-256-gcm",
      "timeout": 7200
    }
  ],
  "mode": "tcp_and_udp"
}
```


更多配置选项请参考 [shadowsocks-rust 官方文档](https://github.com/shadowsocks/shadowsocks-rust)。

## 自动构建

本项目使用 GitHub Actions 自动构建：

- **定时构建**：每小时检查一次新版本
- **手动触发**：可在 Actions 页面手动指定版本构建
- **版本检测**：自动检测并构建最新版本，避免重复构建
- **多变体构建**：同时构建 Debian/Alpine 和 Server/Client 变体

### 手动触发构建

1. 进入仓库的 Actions 页面
2. 选择 "Build and Push Docker Images" workflow
3. 点击 "Run workflow"
4. 可选填：
   - `version`: 指定版本号（如 `v1.17.0`），留空则使用最新版本
   - `debian_version`: Debian 基础镜像版本（默认 `stable`）
   - `force_build`: 强制构建已存在的版本

## 镜像仓库

- **GitHub Container Registry**: `ghcr.io/cary17/shadowsocks-rust:latest`
- **Docker Hub**（可选）: `cary17/shadowsocks-rust:latest`

## 选择合适的镜像

### 何时使用 Debian 镜像
- 需要更好的兼容性
- 对镜像体积不敏感
- 生产环境推荐

### 何时使用 Alpine 镜像
- 追求极致的镜像体积
- 资源受限的环境
- 支持更多架构（包括 386）

### Server vs Client
- **Server**: 用于搭建 Shadowsocks 服务端
- **Client**: 用于客户端代理，提供 SOCKS5 代理服务
