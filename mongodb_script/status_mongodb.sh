#!/bin/bash

# MongoDB状态查看脚本
# 作者: AI助手
# 用途: 查看MongoDB服务状态

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
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

# 获取MongoDB进程信息
get_process_info() {
    # 查找真正的mongod进程
    local mongod_process=$(ps aux | grep -v grep | grep "mongod --dbpath")
    if [ -n "$mongod_process" ]; then
        local pid=$(echo "$mongod_process" | awk '{print $2}')
        echo "MongoDB进程ID: $pid"
        echo "进程详细信息:"
        ps -p "$pid" -o pid,ppid,cmd,etime,pcpu,pmem 2>/dev/null || true
    else
        echo "未找到MongoDB进程"
    fi
}

# 获取MongoDB版本信息
get_version_info() {
    if command -v mongod &> /dev/null; then
        echo "MongoDB版本: $(mongod --version | head -n1)"
    else
        echo "MongoDB未安装或不在PATH中"
    fi
}

# 检查端口状态
check_port_status() {
    local port=27017
    if netstat -tuln 2>/dev/null | grep -q ":$port "; then
        echo "端口 $port 状态: 正在监听"
        netstat -tuln | grep ":$port "
    else
        echo "端口 $port 状态: 未监听"
    fi
}

# 检查MongoDB连接
check_connection() {
    log_info "检查MongoDB连接..."
    
    # 首先检查端口是否在监听
    if ! netstat -tuln 2>/dev/null | grep -q ":27017 "; then
        log_error "MongoDB端口27017未监听"
        return 1
    fi
    
    # 尝试连接
    if command -v mongosh &> /dev/null; then
        # 使用mongosh，指定明确的连接地址
        if timeout 5 mongosh --host 127.0.0.1:27017 --eval "db.runCommand('ping')" --quiet 2>/dev/null; then
            log_success "MongoDB连接正常"
            return 0
        fi
    elif command -v mongo &> /dev/null; then
        # 使用mongo，指定明确的连接地址
        if timeout 5 mongo --host 127.0.0.1:27017 --eval "db.runCommand('ping')" --quiet 2>/dev/null; then
            log_success "MongoDB连接正常"
            return 0
        fi
    fi
    
    log_error "无法连接到MongoDB"
    return 1
}

# 获取数据库信息
get_database_info() {
    log_info "获取数据库信息..."
    
    if command -v mongosh &> /dev/null; then
        mongosh --eval "
            print('=== 数据库列表 ===');
            db.adminCommand('listDatabases').databases.forEach(function(db) {
                print('数据库: ' + db.name + ', 大小: ' + (db.sizeOnDisk / 1024 / 1024).toFixed(2) + ' MB');
            });
            print('\\n=== 服务器状态 ===');
            printjson(db.serverStatus().host);
            print('运行时间: ' + db.serverStatus().uptime + ' 秒');
            print('连接数: ' + db.serverStatus().connections.current);
        " --quiet 2>/dev/null || log_warn "无法获取数据库信息"
    elif command -v mongo &> /dev/null; then
        mongo --eval "
            print('=== 数据库列表 ===');
            db.adminCommand('listDatabases').databases.forEach(function(db) {
                print('数据库: ' + db.name + ', 大小: ' + (db.sizeOnDisk / 1024 / 1024).toFixed(2) + ' MB');
            });
            print('\\n=== 服务器状态 ===');
            printjson(db.serverStatus().host);
            print('运行时间: ' + db.serverStatus().uptime + ' 秒');
            print('连接数: ' + db.serverStatus().connections.current);
        " --quiet 2>/dev/null || log_warn "无法获取数据库信息"
    fi
}

# 检查日志文件
check_log_files() {
    local log_file="/var/log/mongodb/mongod.log"
    if [ -f "$log_file" ]; then
        echo "=== 最近的日志信息 ==="
        tail -n 10 "$log_file"
    else
        echo "日志文件不存在: $log_file"
    fi
}

# 检查配置文件
check_config_files() {
    local config_files=(
        "/etc/mongod.conf"
        "/etc/mongodb.conf"
        "/usr/local/etc/mongod.conf"
    )
    
    echo "=== 配置文件检查 ==="
    for config in "${config_files[@]}"; do
        if [ -f "$config" ]; then
            echo "找到配置文件: $config"
        fi
    done
}

# 检查systemd服务状态
check_systemd_status() {
    if systemctl is-active --quiet mongod 2>/dev/null; then
        echo "=== systemd服务状态 ==="
        systemctl status mongod --no-pager -l
    else
        echo "MongoDB未作为systemd服务运行"
    fi
}

# 主状态检查函数
check_mongodb_status() {
    echo "=========================================="
    echo "        MongoDB 状态检查"
    echo "=========================================="
    
    # 基本状态
    echo -e "\n${BLUE}=== 基本状态 ===${NC}"
    if check_mongodb_running; then
        log_success "MongoDB正在运行"
    else
        log_error "MongoDB未运行"
    fi
    
    # 版本信息
    echo -e "\n${BLUE}=== 版本信息 ===${NC}"
    get_version_info
    
    # 进程信息
    echo -e "\n${BLUE}=== 进程信息 ===${NC}"
    get_process_info
    
    # 端口状态
    echo -e "\n${BLUE}=== 端口状态 ===${NC}"
    check_port_status
    
    # 连接测试
    echo -e "\n${BLUE}=== 连接测试 ===${NC}"
    if check_connection; then
        # 获取数据库信息
        echo -e "\n${BLUE}=== 数据库信息 ===${NC}"
        get_database_info
    fi
    
    # 配置文件
    echo -e "\n${BLUE}=== 配置文件 ===${NC}"
    check_config_files
    
    # systemd状态
    echo -e "\n${BLUE}=== systemd服务状态 ===${NC}"
    check_systemd_status
    
    # 日志信息
    echo -e "\n${BLUE}=== 日志信息 ===${NC}"
    check_log_files
    
    echo "=========================================="
    echo "        状态检查完成"
    echo "=========================================="
}

# 主函数
main() {
    check_mongodb_status
}

# 执行主函数
main "$@"
