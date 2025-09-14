# MongoDB 管理脚本集合

这是一套完整的MongoDB管理脚本，提供了启动、停止、重启、状态查看等常用功能。

## 脚本列表

### 1. 核心管理脚本

- **`mongodb_manager.sh`** - 统一管理脚本（推荐使用）
- **`start_mongodb.sh`** - 启动MongoDB服务
- **`stop_mongodb.sh`** - 停止MongoDB服务
- **`restart_mongodb.sh`** - 重启MongoDB服务
- **`status_mongodb.sh`** - 查看MongoDB状态

## 使用方法

### 统一管理脚本（推荐）

```bash
# 查看帮助
./mongodb_manager.sh help

# 启动MongoDB
./mongodb_manager.sh start

# 停止MongoDB
./mongodb_manager.sh stop

# 重启MongoDB
./mongodb_manager.sh restart

# 查看状态
./mongodb_manager.sh status

# 查看日志
./mongodb_manager.sh logs

# 连接到MongoDB
./mongodb_manager.sh connect

# 备份数据
./mongodb_manager.sh backup

# 恢复数据
./mongodb_manager.sh restore
```

### 单独使用脚本

```bash
# 启动MongoDB
./start_mongodb.sh

# 停止MongoDB
./stop_mongodb.sh

# 重启MongoDB
./restart_mongodb.sh

# 查看状态
./status_mongodb.sh
```

## 功能特性

### 启动脚本 (`start_mongodb.sh`)
- 自动检查MongoDB是否已安装
- 检查服务是否已在运行
- 创建必要的数据和日志目录
- 支持systemd和手动启动两种方式
- 自动设置正确的文件权限
- 启动后验证服务状态

### 停止脚本 (`stop_mongodb.sh`)
- 优雅停止MongoDB（发送shutdown命令）
- 支持强制停止（SIGTERM/SIGKILL）
- 支持systemd和手动停止两种方式
- 停止后验证服务状态

### 重启脚本 (`restart_mongodb.sh`)
- 先停止再启动的完整重启流程
- 支持systemd和手动重启两种方式
- 重启后验证服务状态

### 状态查看脚本 (`status_mongodb.sh`)
- 检查MongoDB进程状态
- 显示版本信息
- 检查端口监听状态
- 测试数据库连接
- 显示数据库列表和大小
- 显示服务器状态信息
- 检查配置文件
- 显示systemd服务状态
- 查看最近的日志信息

### 统一管理脚本 (`mongodb_manager.sh`)
- 提供统一的命令行接口
- 集成所有管理功能
- 支持日志查看
- 支持数据库连接
- 支持数据备份和恢复

## 系统要求

- Linux系统
- MongoDB已安装
- bash shell
- 适当的权限（某些操作需要sudo）

## 安装MongoDB

如果MongoDB未安装，可以使用以下命令安装：

### Ubuntu/Debian
```bash
# 导入MongoDB公钥
wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | sudo apt-key add -

# 添加MongoDB仓库
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list

# 更新包列表
sudo apt-get update

# 安装MongoDB
sudo apt-get install -y mongodb-org
```

### CentOS/RHEL
```bash
# 创建MongoDB仓库文件
sudo vim /etc/yum.repos.d/mongodb-org-6.0.repo

# 添加以下内容：
[mongodb-org-6.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/6.0/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-6.0.asc

# 安装MongoDB
sudo yum install -y mongodb-org
```

## 配置说明

### 数据目录
- 默认数据目录：`/var/lib/mongodb`
- 默认日志目录：`/var/log/mongodb`
- 默认日志文件：`/var/log/mongodb/mongod.log`

### 端口配置
- 默认端口：27017
- 连接字符串：`mongodb://localhost:27017/`

## 故障排除

### 常见问题

1. **权限问题**
   ```bash
   # 确保MongoDB用户有正确的权限
   sudo chown -R mongodb:mongodb /var/lib/mongodb
   sudo chown -R mongodb:mongodb /var/log/mongodb
   ```

2. **端口被占用**
   ```bash
   # 检查端口使用情况
   netstat -tuln | grep 27017
   lsof -i :27017
   ```

3. **服务无法启动**
   ```bash
   # 查看详细错误信息
   tail -f /var/log/mongodb/mongod.log
   ```

4. **连接失败**
   ```bash
   # 检查防火墙设置
   sudo ufw status
   sudo firewall-cmd --list-ports
   ```

## 日志文件位置

- 主日志：`/var/log/mongodb/mongod.log`
- 系统日志：`/var/log/syslog`（systemd服务）
- 错误日志：`/var/log/mongodb/mongod.log`

## 注意事项

1. 在生产环境中使用前，请仔细测试所有脚本
2. 备份操作会创建完整的数据备份
3. 恢复操作会覆盖现有数据，请谨慎使用
4. 某些操作需要root权限或sudo权限
5. 建议定期备份重要数据

## 许可证

本脚本集合遵循MIT许可证，可自由使用和修改。
