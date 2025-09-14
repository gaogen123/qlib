# MongoDB 脚本快速使用指南

## 🚀 快速开始

### 1. 查看所有可用命令
```bash
./mongodb_manager.sh help
```

### 2. 启动MongoDB
```bash
./mongodb_manager.sh start
```

### 3. 查看MongoDB状态
```bash
./mongodb_manager.sh status
```

### 4. 停止MongoDB
```bash
./mongodb_manager.sh stop
```

### 5. 重启MongoDB
```bash
./mongodb_manager.sh restart
```

## 📋 常用操作

### 查看日志
```bash
# 查看最近50行日志
./mongodb_manager.sh logs

# 实时查看日志
tail -f /var/log/mongodb/mongod.log
```

### 连接数据库
```bash
# 使用mongosh连接
./mongodb_manager.sh connect

# 或者直接使用mongosh
mongosh
```

### 备份和恢复
```bash
# 备份数据
./mongodb_manager.sh backup

# 恢复数据
./mongodb_manager.sh restore
```

## 🔧 单独使用脚本

如果不想使用统一管理脚本，也可以单独使用各个脚本：

```bash
# 启动
./start_mongodb.sh

# 停止
./stop_mongodb.sh

# 重启
./restart_mongodb.sh

# 查看状态
./status_mongodb.sh
```

## ⚡ 一键操作

### 检查并启动MongoDB
```bash
# 如果MongoDB未运行则启动
if ! pgrep -f "mongod" > /dev/null; then
    ./mongodb_manager.sh start
fi
```

### 重启MongoDB并查看状态
```bash
./mongodb_manager.sh restart && ./mongodb_manager.sh status
```

## 🐛 故障排除

### MongoDB无法启动
1. 检查端口是否被占用：`netstat -tuln | grep 27017`
2. 查看错误日志：`tail -f /var/log/mongodb/mongod.log`
3. 检查权限：`ls -la /var/lib/mongodb`

### 连接失败
1. 确认MongoDB正在运行：`./mongodb_manager.sh status`
2. 检查防火墙设置
3. 确认端口27017可访问

### 权限问题
```bash
# 修复数据目录权限
sudo chown -R mongodb:mongodb /var/lib/mongodb
sudo chown -R mongodb:mongodb /var/log/mongodb
```

## 📝 注意事项

- 所有脚本都需要执行权限
- 某些操作需要sudo权限
- 备份和恢复操作会创建/覆盖数据
- 建议在生产环境使用前充分测试

## 🔗 相关文件

- 数据目录：`/var/lib/mongodb`
- 日志文件：`/var/log/mongodb/mongod.log`
- 配置文件：`/etc/mongod.conf`
- 备份目录：`/var/backups/mongodb`
