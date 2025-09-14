#!/bin/bash

# MongoDB重启脚本
# 作者: AI助手
# 用途: 重启MongoDB服务

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

# 重启MongoDB
restart_mongodb() {
    log_info "正在重启MongoDB..."
    
    # 检查MongoDB是否运行
    if check_mongodb_running; then
        log_info "MongoDB正在运行，先停止服务..."
        
        # 尝试使用systemd重启
        if systemctl is-active --quiet mongod 2>/dev/null; then
            log_info "使用systemd重启MongoDB..."
            sudo systemctl restart mongod
            if [ $? -eq 0 ]; then
                log_info "MongoDB重启成功"
                return 0
            else
                log_error "systemd重启失败"
                exit 1
            fi
        else
            # 手动重启
            log_info "手动重启MongoDB..."
            
            # 停止MongoDB
            log_info "停止MongoDB..."
            if command -v mongosh &> /dev/null; then
                mongosh --eval "db.adminCommand('shutdown')" admin 2>/dev/null || true
            elif command -v mongo &> /dev/null; then
                mongo --eval "db.adminCommand('shutdown')" admin 2>/dev/null || true
            fi
            
            # 等待停止
            local count=0
            while check_mongodb_running && [ $count -lt 10 ]; do
                log_info "等待MongoDB停止... ($((count+1))/10)"
                sleep 1
                count=$((count+1))
            done
            
            # 如果还在运行，强制停止
            if check_mongodb_running; then
                log_warn "优雅停止失败，强制停止..."
                pkill -f "mongod" 2>/dev/null || true
                sleep 2
            fi
        fi
    else
        log_info "MongoDB未运行，直接启动..."
    fi
    
    # 启动MongoDB
    log_info "启动MongoDB..."
    
    # 创建必要的目录
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
    
    # 启动MongoDB
    if systemctl is-enabled --quiet mongod 2>/dev/null; then
        log_info "使用systemd启动MongoDB..."
        sudo systemctl start mongod
    else
        # 手动启动
        log_info "手动启动MongoDB..."
        local log_file="/var/log/mongodb/mongod.log"
        
        sudo -u mongodb mongod --dbpath "$data_dir" --logpath "$log_file" --fork 2>/dev/null || {
            log_warn "使用mongodb用户启动失败，尝试使用当前用户启动..."
            mongod --dbpath "$data_dir" --logpath "$log_file" --fork 2>/dev/null || {
                log_error "MongoDB启动失败"
                exit 1
            }
        }
    fi
    
    # 等待MongoDB完全启动
    log_info "等待MongoDB完全启动..."
    sleep 3
    
    # 验证MongoDB是否正常运行
    if check_mongodb_running; then
        log_info "MongoDB重启成功并运行在端口27017"
        echo "连接字符串: mongodb://localhost:27017/"
    else
        log_error "MongoDB重启后未能正常运行"
        exit 1
    fi
}

# 主函数
main() {
    echo "=========================================="
    echo "        MongoDB 重启脚本"
    echo "=========================================="
    
    restart_mongodb
    
    echo "=========================================="
    echo "        MongoDB 重启完成"
    echo "=========================================="
}

# 执行主函数
main "$@"
