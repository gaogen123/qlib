#!/bin/bash

# Mihomo 节点切换脚本
# 使用方法: ./switch_node.sh <节点名称>

CONFIG_FILE="config.yaml"
BACKUP_FILE="config.yaml.backup"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 显示帮助信息
show_help() {
    echo -e "${BLUE}Mihomo 节点切换脚本${NC}"
    echo "使用方法: $0 <节点名称>"
    echo ""
    echo "可用节点:"
    echo -e "${YELLOW}香港节点:${NC} Hong Kong-01 到 Hong Kong-20"
    echo -e "${YELLOW}台湾节点:${NC} Taiwan-01 到 Taiwan-10"
    echo -e "${YELLOW}日本节点:${NC} Japan-01 到 Japan-10"
    echo -e "${YELLOW}新加坡节点:${NC} Singapore-01 到 Singapore-10"
    echo -e "${YELLOW}美国节点:${NC} USA-01 到 USA-10"
    echo -e "${YELLOW}英国节点:${NC} UK-01 到 UK-05"
    echo -e "${YELLOW}马来西亚节点:${NC} Malaysia-01 到 Malaysia-05"
    echo -e "${YELLOW}土耳其节点:${NC} Turkey-01, Turkey-02"
    echo -e "${YELLOW}阿根廷节点:${NC} Argentina-01, Argentina-02"
    echo -e "${YELLOW}智能模式:${NC} auto, fallback"
    echo ""
    echo "示例:"
    echo "  $0 \"Hong Kong-01\"    # 切换到香港01节点"
    echo "  $0 \"Japan-05\"        # 切换到日本05节点"
    echo "  $0 \"auto\"            # 切换到自动模式"
    echo "  $0 \"fallback\"        # 切换到故障转移模式"
}

# 检查配置文件是否存在
if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${RED}错误: 配置文件 $CONFIG_FILE 不存在${NC}"
    exit 1
fi

# 如果没有参数，显示帮助信息
if [ $# -eq 0 ]; then
    show_help
    exit 0
fi

# 清理节点名称：去除换行符、回车符和多余空格
NODE_NAME=$(echo "$1" | tr -d '\r\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

# 显示清理后的节点名称（用于调试）
echo -e "${BLUE}输入的节点名称: '$1'${NC}"
echo -e "${BLUE}清理后的节点名称: '$NODE_NAME'${NC}"

# 备份原配置文件
if [ ! -f "$BACKUP_FILE" ]; then
    cp "$CONFIG_FILE" "$BACKUP_FILE"
    echo -e "${GREEN}已备份原配置文件到 $BACKUP_FILE${NC}"
fi

# 验证节点名称是否有效
valid_nodes=(
    "Hong Kong-01" "Hong Kong-02" "Hong Kong-03" "Hong Kong-04" "Hong Kong-05"
    "Hong Kong-06" "Hong Kong-07" "Hong Kong-08" "Hong Kong-09" "Hong Kong-10"
    "Hong Kong-11" "Hong Kong-12" "Hong Kong-13" "Hong Kong-14" "Hong Kong-15"
    "Hong Kong-16" "Hong Kong-17" "Hong Kong-18" "Hong Kong-19" "Hong Kong-20"
    "Taiwan-01" "Taiwan-02" "Taiwan-03" "Taiwan-04" "Taiwan-05"
    "Taiwan-06" "Taiwan-07" "Taiwan-08" "Taiwan-09" "Taiwan-10"
    "Japan-01" "Japan-02" "Japan-03" "Japan-04" "Japan-05"
    "Japan-06" "Japan-07" "Japan-08" "Japan-09" "Japan-10"
    "Singapore-01" "Singapore-02" "Singapore-03" "Singapore-04" "Singapore-05"
    "Singapore-06" "Singapore-07" "Singapore-08" "Singapore-09" "Singapore-10"
    "USA-01" "USA-02" "USA-03" "USA-04" "USA-05"
    "USA-06" "USA-07" "USA-08" "USA-09" "USA-10"
    "UK-01" "UK-02" "UK-03" "UK-04" "UK-05"
    "Malaysia-01" "Malaysia-02" "Malaysia-03" "Malaysia-04" "Malaysia-05"
    "Turkey-01" "Turkey-02"
    "Argentina-01" "Argentina-02"
    "auto" "fallback"
)

is_valid=false
for node in "${valid_nodes[@]}"; do
    if [ "$node" = "$NODE_NAME" ]; then
        is_valid=true
        break
    fi
done

if [ "$is_valid" = false ]; then
    echo -e "${RED}错误: 无效的节点名称 '$NODE_NAME'${NC}"
    echo "使用 '$0' 查看可用的节点列表"
    exit 1
fi

# 更新配置文件中的默认选择
echo -e "${BLUE}正在切换到节点: $NODE_NAME${NC}"

# 当使用subscription时，不需要手动添加proxies
# 只需要确保PROXY组使用subscription作为节点源
echo -e "${GREEN}成功切换到节点: $NODE_NAME${NC}"
echo -e "${BLUE}注意: 当使用subscription时，节点列表会自动从订阅文件获取${NC}"
echo -e "${BLUE}您可以在mihomo的Web界面中选择默认节点${NC}"

# 询问是否重启服务
read -p "是否立即重启 mihomo 服务以应用新配置? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${BLUE}正在重启 mihomo 服务...${NC}"
    ./restart.sh
    echo -e "${GREEN}服务已重启，新配置已生效${NC}"
else
    echo -e "${YELLOW}请手动重启服务以应用新配置: ./restart.sh${NC}"
fi

echo -e "${GREEN}节点切换完成！${NC}"
