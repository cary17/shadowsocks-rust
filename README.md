# Shadowsocks-Rust Docker 镜像

基于 [shadowsocks-rust](https://github.com/shadowsocks/shadowsocks-rust) 的 Docker 镜像，提供最小化的容器部署方案。

## 🌟 特性

- **🐳 多架构支持**：`linux/amd64`, `linux/arm64`, `linux/arm/v7` (Debian) / 额外支持 `linux/386` (Alpine)
- **📦 最小化镜像**：基于 Alpine 和 Debian-slim 构建，体积最小
- **🎯 变体分离**：Server 和 Client 独立镜像，避免冗余
- **🔄 自动更新**：GitHub Actions 自动检测新版本并构建
- **📝 配置生成**：Server 镜像支持通过环境变量自动生成配置
- **🔧 多平台发布**：自动发布到 GitHub Container Registry 和 Docker Hub

## 🏷️ 镜像标签

### Debian 基础镜像
- `latest` / `vX.Y.Z` - 服务器变体（默认）
- `latest-server-debian` / `vX.Y.Z-server-debian` - 服务器变体
- `latest-client-debian` / `vX.Y.Z-client-debian` - 客户端变体

### Alpine 基础镜像
- `latest-server-alpine` / `vX.Y.Z-server-alpine` - 服务器变体
- `latest-client-alpine` / `vX.Y.Z-client-alpine` - 客户端变体

## 🚀 快速开始

### 1. 服务器部署（使用环境变量）

```bash
# 使用 Debian 镜像
docker run -d \
  --name ss-server \
  -p 8388:8388 \
  -p 8388:8388/udp \
  -e SS_SERVER_PORT=8388 \
  -e SS_PASSWORD=your-password \
  -e SS_METHOD=aes-256-gcm \
  ghcr.io/cary17/shadowsocks-rust:latest

# 使用 Alpine 镜像（更小体积）
docker run -d \
  --name ss-server \
  -p 8388:8388 \
  -p 8388:8388/udp \
  -e SS_SERVER_PORT=8388 \
  -e SS_PASSWORD=your-password \
  -e SS_METHOD=aes-256-gcm \
  ghcr.io/cary17/shadowsocks-rust:latest-server-alpine
```

### 2. 服务器部署（使用配置文件）

```bash
# 创建配置文件
cat > config.json << EOF
{
  "servers": [
    {
      "server": "::",
      "server_port": 8388,
      "password": "your-password",
      "method": "aes-256-gcm",
      "timeout": 7200,
      "mode": "tcp_and_udp"
    }
  ]
}
EOF

# 运行容器
docker run -d \
  --name ss-server \
  -p 8388:8388 \
  -p 8388:8388/udp \
  -v $(pwd)/config.json:/etc/ss-rust/config.json \
  ghcr.io/cary17/shadowsocks-rust:latest
```

### 3. 客户端部署

```bash
# 创建客户端配置
cat > client-config.json << EOF
{
  "server": "your-server-ip",
  "server_port": 8388,
  "password": "your-password",
  "method": "aes-256-gcm",
  "local_address": "0.0.0.0",
  "local_port": 1080,
  "timeout": 7200
}
EOF

# 运行客户端
docker run -d \
  --name ss-client \
  -p 1080:1080 \
  -p 1080:1080/udp \
  -v $(pwd)/client-config.json:/etc/ss-rust/config.json \
  ghcr.io/cary17/shadowsocks-rust:latest-client-debian
```

## 🔧 环境变量配置

### 服务器镜像支持的变量

#### 基本配置（必需）
- `SS_SERVER_PORT` - 服务器端口
- `SS_PASSWORD` - 密码
- `SS_METHOD` - 加密方法（如：aes-256-gcm, chacha20-ietf-poly1305 等）

#### 多端口配置
- `SS_SERVER_PORT_1`, `SS_PASSWORD_1`, `SS_METHOD_1`
- `SS_SERVER_PORT_2`, `SS_PASSWORD_2`, `SS_METHOD_2`
- ...（支持多个端口配置）

#### 高级配置（可选）
- `SS_MODE` - 模式（默认：`tcp_and_udp`）
- `SS_TIMEOUT` - 超时时间（秒，默认：7200）
- `SS_DNS` - DNS 服务器地址
- `SS_IPV6_FIRST` - IPv6 优先（true/false，默认：false）
- `SS_IPV6_ONLY` - 仅 IPv6（true/false，默认：false）

#### 单服务器可选参数
- `SS_SERVER` - 监听地址（默认：`::`）
- `SS_DISABLED` - 禁用此服务器（true/false，默认：false）
- `SS_TCP_WEIGHT` - TCP 权重（默认：1.0）
- `SS_UDP_WEIGHT` - UDP 权重（默认：1.0）
- `SS_OUTBOUND_BIND_INTERFACE` - 出站绑定接口
- `SS_OUTBOUND_BIND_ADDR` - 出站绑定地址
- `SS_OUTBOUND_FWMARK` - 出站防火墙标记
- `SS_OUTBOUND_UDP_ALLOW_FRAGMENTATION` - 允许 UDP 分片（true/false，默认：false）

## 📊 多端口配置示例

```bash
docker run -d \
  --name ss-server \
  -p 8388:8388 \
  -p 8389:8389 \
  -p 8390:8390 \
  -e SS_SERVER_PORT_1=8388 \
  -e SS_PASSWORD_1=password1 \
  -e SS_METHOD_1=aes-256-gcm \
  -e SS_SERVER_PORT_2=8389 \
  -e SS_PASSWORD_2=password2 \
  -e SS_METHOD_2=chacha20-ietf-poly1305 \
  -e SS_SERVER_PORT_3=8390 \
  -e SS_PASSWORD_3=password3 \
  -e SS_METHOD_3=aes-128-gcm \
  -e SS_MODE=tcp_and_udp \
  ghcr.io/cary17/shadowsocks-rust:latest
```

## 📄 配置参考

### 服务器配置文件示例

```json
{
  "servers": [
    {
      "server": "::",
      "server_port": 8388,
      "password": "password1",
      "method": "aes-256-gcm",
      "timeout": 7200,
      "tcp_weight": 1.0,
      "udp_weight": 1.0,
      "mode": "tcp_and_udp"
    },
    {
      "server": "::",
      "server_port": 8389,
      "password": "password2",
      "method": "chacha20-ietf-poly1305",
      "timeout": 7200,
      "disabled": false
    }
  ],
  "mode": "tcp_and_udp",
  "dns": "8.8.8.8",
  "ipv6_first": false,
  "ipv6_only": false
}
```

### 客户端配置文件示例

```json
{
  "server": "your-server-ip",
  "server_port": 8388,
  "password": "your-password",
  "method": "aes-256-gcm",
  "local_address": "0.0.0.0",
  "local_port": 1080,
  "timeout": 7200,
  "fast_open": false
}
```

## 🖥️ 支持的架构

### Debian 镜像
- `linux/amd64`
- `linux/arm64`
- `linux/arm/v7`

### Alpine 镜像
- `linux/amd64`
- `linux/arm64`
- `linux/arm/v7`
- `linux/386`

## 📦 版本管理

镜像版本与上游 shadowsocks-rust 版本保持一致：
- 主标签：`vX.Y.Z`（对应 shadowsocks-rust 版本）
- 最新标签：`latest`（始终指向最新稳定版）


## 📦 镜像仓库

### GHCR (推荐)
```bash
ghcr.io/cary17/shadowsocks-rust:latest
ghcr.io/cary17/shadowsocks-rust:5.0.1
```

### Docker Hub
```bash
cary17/shadowsocks-rust:latest
cary17e/shadowsocks-rust:5.0.1
```
