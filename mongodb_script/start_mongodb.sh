#!/bin/bash

# MongoDB启动脚本
# 作者: AI助手
# 用途: 启动MongoDB服务

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

# 检查MongoDB是否已经运行
check_mongodb_running() {
    # 使用更精确的进程检测，查找真正的mongod进程
    if ps aux | grep -v grep | grep -q "mongod --dbpath"; then
        log_warn "MongoDB已经在运行中"
        return 0
    else
        return 1
    fi
}

# 检查MongoDB是否安装
check_mongodb_installed() {
    if ! command -v mongod &> /dev/null; then
        log_error "MongoDB未安装，请先安装MongoDB"
        exit 1
    fi
}

# 创建数据目录
create_data_dir() {
    local data_dir="/var/lib/mongodb"
    local log_dir="/var/log/mongodb"
    
    if [ ! -d "$data_dir" ]; then
        log_info "创建数据目录: $data_dir"
        sudo mkdir -p "$data_dir"
        sudo chown mongodb:mongodb "$data_dir" 2>/dev/null || true
    fi
    
    if [ ! -d "$log_dir" ]; then
        log_info "创建日志目录: $log_dir"
        sudo mkdir -p "$log_dir"
        sudo chown mongodb:mongodb "$log_dir" 2>/dev/null || true
    fi
}

# 启动MongoDB
start_mongodb() {
    log_info "正在启动MongoDB..."
    
    # 检查是否已经运行
    if check_mongodb_running; then
        log_warn "MongoDB已经在运行，无需重复启动"
        exit 0
    fi
    
    # 检查MongoDB是否安装
    check_mongodb_installed
    
    # 创建必要的目录
    create_data_dir
    
    # 尝试使用systemd启动
    if systemctl is-active --quiet mongod 2>/dev/null; then
        log_info "使用systemd启动MongoDB..."
        sudo systemctl start mongod
        if [ $? -eq 0 ]; then
            log_info "MongoDB启动成功"
        else
            log_error "MongoDB启动失败"
            exit 1
        fi
    else
        # 手动启动MongoDB
        log_info "手动启动MongoDB..."
        local data_dir="/var/lib/mongodb"
        local log_file="/var/log/mongodb/mongod.log"
        
        # 启动MongoDB守护进程
        sudo -u mongodb mongod --dbpath "$data_dir" --logpath "$log_file" --fork 2>/dev/null || {
            log_warn "使用mongodb用户启动失败，尝试使用当前用户启动..."
            mongod --dbpath "$data_dir" --logpath "$log_file" --fork 2>/dev/null || {
                log_error "MongoDB启动失败"
                exit 1
            }
        }
        
        log_info "MongoDB启动成功"
    fi
    
    # 等待MongoDB完全启动
    log_info "等待MongoDB完全启动..."
    sleep 3
    
    # 验证MongoDB是否正常运行
    if check_mongodb_running; then
        log_info "MongoDB已成功启动并运行在端口27017"
        echo "连接字符串: mongodb://localhost:27017/"
    else
        log_error "MongoDB启动后未能正常运行"
        exit 1
    fi
}

# 主函数
main() {
    echo "=========================================="
    echo "        MongoDB 启动脚本"
    echo "=========================================="
    
    start_mongodb
    
    echo "=========================================="
    echo "        MongoDB 启动完成"
    echo "=========================================="
}

# 执行主函数
main "$@"
