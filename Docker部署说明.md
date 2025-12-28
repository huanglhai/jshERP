# jshERP Docker 部署说明文档

**创建日期：2025-12-27**

## 项目概述

管伊佳ERP（jshERP）是一个开源的进销存+财务+生产管理系统，使用 Docker 进行本地部署，方便快速搭建和运行。

## 一、项目规划

### 1.1 部署架构

采用 Docker Compose 编排以下服务：

- **MySQL 8.0.24**：数据库服务，存储系统数据
- **Redis 6.2.1**：缓存服务，提升系统性能
- **jshERP-boot**：后端 Spring Boot 服务（端口 9999）
- **jshERP-web**：前端 Vue + Nginx 服务（端口 80）

### 1.2 网络配置

所有服务通过 Docker 网络进行通信，网络名称：jsherp-network

### 1.3 数据持久化

- MySQL 数据：mysql-data 卷
- Redis 数据：redis-data 卷
- 上传文件：./upload 目录
- 临时文件：./tmp 目录

## 二、实施方案

### 2.1 环境要求

- **操作系统**：Windows / Linux / macOS
- **Docker**：20.10+
- **Docker Compose**：2.0+

### 2.2 部署步骤

#### 步骤 1：准备项目文件

确保项目目录结构如下：

```
jshERP/
├── docker-compose.yml          # Docker 编排文件
├── .env                        # 环境变量配置
├── jshERP-boot/
│   ├── Dockerfile             # 后端镜像构建文件
│   ├── .dockerignore          # 后端忽略文件
│   ├── pom.xml
│   └── src/
├── jshERP-web/
│   ├── Dockerfile             # 前端镜像构建文件
│   ├── .dockerignore          # 前端忽略文件
│   ├── nginx.conf             # Nginx 配置文件
│   ├── package.json
│   └── src/
└── upload/                     # 上传文件目录（自动创建）
```

#### 步骤 2：启动服务

在项目根目录执行：

```bash
docker-compose up -d
```

首次启动会自动：
1. 下载并启动 MySQL、Redis 镜像
2. 初始化数据库（执行 jsh_erp.sql）
3. 构建并启动后端服务
4. 构建并启动前端服务

#### 步骤 3：查看服务状态

```bash
docker-compose ps
```

#### 步骤 4：查看日志

查看所有服务日志：
```bash
docker-compose logs -f
```

查看特定服务日志：
```bash
docker-compose logs -f jsherp-boot
docker-compose logs -f jsherp-web
```

### 2.3 访问系统

- **前端访问地址**：http://localhost
- **后端 API 地址**：http://localhost:9999/jshERP-boot
- **数据库连接**：localhost:3306

### 2.4 默认登录信息

- **租户账号**：jsh
- **管理员账号**：admin
- **密码**：123456

## 三、进度记录

### 2025-12-27

- ✅ 创建后端 Dockerfile（jshERP-boot/Dockerfile）
- ✅ 创建前端 Dockerfile（jshERP-web/Dockerfile）
- ✅ 创建 Nginx 配置文件（jshERP-web/nginx.conf）
- ✅ 创建 docker-compose.yml 编排文件
- ✅ 创建环境变量配置文件（.env）
- ✅ 创建 .dockerignore 文件
- ✅ 创建 Docker 部署说明文档

## 四、常用命令

### 4.1 服务管理

```bash
# 启动所有服务
docker-compose up -d

# 停止所有服务
docker-compose stop

# 重启所有服务
docker-compose restart

# 停止并删除所有容器
docker-compose down

# 停止并删除所有容器、网络、卷
docker-compose down -v
```

### 4.2 镜像管理

```bash
# 重新构建镜像
docker-compose build

# 重新构建并启动
docker-compose up -d --build

# 删除所有镜像
docker-compose down --rmi all
```

### 4.3 数据管理

```bash
# 备份数据库
docker exec jsherp-mysql mysqldump -uroot -p123456 jsh_erp > backup.sql

# 恢复数据库
docker exec -i jsherp-mysql mysql -uroot -p123456 jsh_erp < backup.sql
```

## 五、故障排查

### 5.1 端口冲突

如果 80 或 9999 端口被占用，修改 docker-compose.yml 中的端口映射：

```yaml
ports:
  - "8080:80"    # 将前端改为 8080 端口
  - "9998:9999"  # 将后端改为 9998 端口
```

### 5.2 数据库连接失败

检查 MySQL 服务是否正常启动：
```bash
docker-compose logs mysql
```

### 5.3 Redis 连接失败

检查 Redis 服务是否正常启动：
```bash
docker-compose logs redis
```

### 5.4 前端无法访问后端

检查 Nginx 配置中的代理地址是否正确，确保使用容器名称（jsherp-boot）而非 localhost。

## 六、安全建议

1. **修改默认密码**：首次登录后立即修改管理员密码
2. **修改数据库密码**：修改 .env 文件中的 MYSQL_ROOT_PASSWORD
3. **修改 Redis 密码**：修改 .env 文件中的 REDIS_PASSWORD
4. **限制端口访问**：生产环境建议使用防火墙限制端口访问
5. **定期备份数据**：定期备份数据库和上传文件

## 七、性能优化

1. **调整 MySQL 配置**：根据服务器资源调整 MySQL 配置参数
2. **调整 Redis 配置**：根据实际需求调整 Redis 内存限制
3. **启用 Nginx 缓存**：在 nginx.conf 中添加缓存配置
4. **使用 CDN**：生产环境建议使用 CDN 加速静态资源

## 八、更新升级

### 8.1 更新代码

拉取最新代码后，重新构建并启动：

```bash
git pull
docker-compose down
docker-compose build
docker-compose up -d
```

### 8.2 数据库迁移

如果有数据库结构变更，需要手动执行 SQL 迁移脚本。

## 九、注意事项

1. 首次启动需要较长时间（构建镜像 + 初始化数据库）
2. 确保 Docker 有足够的内存和磁盘空间
3. Windows 用户建议使用 WSL2 运行 Docker
4. 生产环境建议使用外部 MySQL 和 Redis 实例
5. 定期清理 Docker 未使用的资源：`docker system prune -a`

## 十、技术支持

- **官网**：http://www.gyjerp.com
- **QQ**：752718920
- **微信**：shenhua861584
- **用户手册**：https://www.gyjerp.com/doc/archive/user-manual.html
