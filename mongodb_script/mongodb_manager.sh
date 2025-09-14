#!/bin/bash

# MongoDB统一管理脚本
# 作者: AI助手
# 用途: 统一的MongoDB服务管理工具

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# 脚本目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

# 显示帮助信息
show_help() {
    echo -e "${BLUE}MongoDB 管理工具${NC}"
    echo "=========================================="
    echo "用法: $0 [命令]"
    echo ""
    echo "可用命令:"
    echo "  start     启动MongoDB服务"
    echo "  stop      停止MongoDB服务"
    echo "  restart   重启MongoDB服务"
    echo "  status    查看MongoDB状态"
    echo "  logs      查看MongoDB日志"
    echo "  connect   连接到MongoDB"
    echo "  backup    备份MongoDB数据"
    echo "  restore   恢复MongoDB数据"
    echo "  help      显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 start"
    echo "  $0 status"
    echo "  $0 logs"
}

# 启动MongoDB
start_mongodb() {
    log_info "启动MongoDB..."
    bash "$SCRIPT_DIR/start_mongodb.sh"
}

# 停止MongoDB
stop_mongodb() {
    log_info "停止MongoDB..."
    bash "$SCRIPT_DIR/stop_mongodb.sh"
}

# 重启MongoDB
restart_mongodb() {
    log_info "重启MongoDB..."
    bash "$SCRIPT_DIR/restart_mongodb.sh"
}

# 查看状态
status_mongodb() {
    log_info "查看MongoDB状态..."
    bash "$SCRIPT_DIR/status_mongodb.sh"
}

# 查看日志
view_logs() {
    log_info "查看MongoDB日志..."
    
    local log_file="/var/log/mongodb/mongod.log"
    if [ -f "$log_file" ]; then
        echo "=== MongoDB日志 (最后50行) ==="
        tail -n 50 "$log_file"
        echo ""
        echo "实时查看日志请使用: tail -f $log_file"
    else
        log_warn "日志文件不存在: $log_file"
        echo "尝试查找其他日志文件..."
        find /var/log -name "*mongo*" -type f 2>/dev/null | head -5
    fi
}

# 连接到MongoDB
connect_mongodb() {
    log_info "连接到MongoDB..."
    
    # 检查MongoDB是否运行
    if ! ps aux | grep -v grep | grep -q "mongod --dbpath"; then
        log_error "MongoDB未运行，请先启动MongoDB"
        exit 1
    fi
    
    # 尝试连接
    if command -v mongosh &> /dev/null; then
        log_info "使用mongosh连接..."
        mongosh
    elif command -v mongo &> /dev/null; then
        log_info "使用mongo连接..."
        mongo
    else
        log_error "未找到MongoDB客户端工具 (mongosh 或 mongo)"
        exit 1
    fi
}

# 备份MongoDB
backup_mongodb() {
    log_info "备份MongoDB数据..."
    
    # 检查MongoDB是否运行
    if ! ps aux | grep -v grep | grep -q "mongod --dbpath"; then
        log_error "MongoDB未运行，请先启动MongoDB"
        exit 1
    fi
    
    # 创建备份目录
    local backup_dir="/var/backups/mongodb"
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local backup_path="$backup_dir/backup_$timestamp"
    
    log_info "创建备份目录: $backup_path"
    sudo mkdir -p "$backup_path"
    
    # 执行备份
    if command -v mongodump &> /dev/null; then
        log_info "使用mongodump备份数据..."
        mongodump --out "$backup_path"
        log_success "备份完成: $backup_path"
    else
        log_error "mongodump工具未找到，请安装MongoDB工具包"
        exit 1
    fi
}

# 恢复MongoDB
restore_mongodb() {
    log_info "恢复MongoDB数据..."
    
    # 检查MongoDB是否运行
    if ! ps aux | grep -v grep | grep -q "mongod --dbpath"; then
        log_error "MongoDB未运行，请先启动MongoDB"
        exit 1
    fi
    
    # 查找备份文件
    local backup_dir="/var/backups/mongodb"
    if [ ! -d "$backup_dir" ]; then
        log_error "备份目录不存在: $backup_dir"
        exit 1
    fi
    
    # 列出可用的备份
    echo "可用的备份:"
    ls -la "$backup_dir" | grep backup_
    echo ""
    
    read -p "请输入要恢复的备份目录名: " backup_name
    local restore_path="$backup_dir/$backup_name"
    
    if [ ! -d "$restore_path" ]; then
        log_error "备份目录不存在: $restore_path"
        exit 1
    fi
    
    # 确认恢复
    read -p "确认要恢复数据吗？这将覆盖现有数据！(y/N): " confirm
    if [[ $confirm != [yY] ]]; then
        log_info "取消恢复操作"
        exit 0
    fi
    
    # 执行恢复
    if command -v mongorestore &> /dev/null; then
        log_info "使用mongorestore恢复数据..."
        mongorestore "$restore_path"
        log_success "恢复完成"
    else
        log_error "mongorestore工具未找到，请安装MongoDB工具包"
        exit 1
    fi
}

# 主函数
main() {
    case "${1:-help}" in
        start)
            start_mongodb
            ;;
        stop)
            stop_mongodb
            ;;
        restart)
            restart_mongodb
            ;;
        status)
            status_mongodb
            ;;
        logs)
            view_logs
            ;;
        connect)
            connect_mongodb
            ;;
        backup)
            backup_mongodb
            ;;
        restore)
            restore_mongodb
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            log_error "未知命令: $1"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# 执行主函数
main "$@"
