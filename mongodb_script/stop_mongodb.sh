#!/bin/bash

# MongoDB停止脚本
# 作者: AI助手
# 用途: 停止MongoDB服务

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查MongoDB是否运行
check_mongodb_running() {
    # 使用更精确的进程检测，查找真正的mongod进程
    if ps aux | grep -v grep | grep -q "mongod --dbpath"; then
        return 0
    else
        return 1
    fi
}

# 优雅停止MongoDB
graceful_stop() {
    log_info "尝试优雅停止MongoDB..."
    
    # 尝试使用mongo shell发送shutdown命令
    if command -v mongosh &> /dev/null; then
        log_info "使用mongosh发送shutdown命令..."
        mongosh --eval "db.adminCommand('shutdown')" admin 2>/dev/null || true
    elif command -v mongo &> /dev/null; then
        log_info "使用mongo发送shutdown命令..."
        mongo --eval "db.adminCommand('shutdown')" admin 2>/dev/null || true
    fi
    
    # 等待进程优雅退出
    local count=0
    while check_mongodb_running && [ $count -lt 10 ]; do
        log_info "等待MongoDB优雅停止... ($((count+1))/10)"
        sleep 1
        count=$((count+1))
    done
}

# 强制停止MongoDB
force_stop() {
    log_warn "强制停止MongoDB..."
    
    # 查找真正的mongod进程
    local mongod_process=$(ps aux | grep -v grep | grep "mongod --dbpath")
    if [ -n "$mongod_process" ]; then
        local pid=$(echo "$mongod_process" | awk '{print $2}')
        log_info "找到MongoDB进程: $pid"
        
        # 发送SIGTERM信号
        log_info "发送SIGTERM信号..."
        kill -TERM "$pid" 2>/dev/null || true
        
        # 等待进程停止
        sleep 3
        
        # 检查是否还在运行
        if check_mongodb_running; then
            log_warn "SIGTERM无效，发送SIGKILL信号..."
            kill -KILL "$pid" 2>/dev/null || true
            sleep 1
        fi
    fi
}

# 停止MongoDB
stop_mongodb() {
    log_info "正在停止MongoDB..."
    
    # 检查MongoDB是否运行
    if ! check_mongodb_running; then
        log_warn "MongoDB未运行，无需停止"
        return 0
    fi
    
    # 尝试使用systemd停止
    if systemctl is-active --quiet mongod 2>/dev/null; then
        log_info "使用systemd停止MongoDB..."
        sudo systemctl stop mongod
        if [ $? -eq 0 ]; then
            log_info "MongoDB停止成功"
            return 0
        else
            log_warn "systemd停止失败，尝试手动停止..."
        fi
    fi
    
    # 手动停止MongoDB
    log_info "手动停止MongoDB..."
    
    # 首先尝试优雅停止
    graceful_stop
    
    # 检查是否还在运行
    if check_mongodb_running; then
        log_warn "优雅停止失败，尝试强制停止..."
        force_stop
    fi
    
    # 最终检查
    if check_mongodb_running; then
        log_error "MongoDB停止失败"
        exit 1
    else
        log_info "MongoDB已成功停止"
    fi
}

# 主函数
main() {
    echo "=========================================="
    echo "        MongoDB 停止脚本"
    echo "=========================================="
    
    stop_mongodb
    
    echo "=========================================="
    echo "        MongoDB 停止完成"
    echo "=========================================="
}

# 执行主函数
main "$@"
