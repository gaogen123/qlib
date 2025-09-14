#!/bin/bash

# Mihomo 节点列表查看脚本

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

printf "${BLUE}========================================${NC}\n"
printf "${BLUE}        Mihomo 可用节点列表${NC}\n"
printf "${BLUE}========================================${NC}\n"
printf "\n"

printf "${YELLOW}🇭🇰 香港节点 (20个):${NC}\n"
for i in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20; do
    printf "  %-15s" "Hong Kong-$i"
    # 使用更兼容的算术表达式
    num=$(echo $i | sed 's/^0*//')
    if [ $((num % 5)) -eq 0 ]; then printf "\n"; fi
done
printf "\n\n"

printf "${YELLOW}🇹🇼 台湾节点 (10个):${NC}\n"
for i in 01 02 03 04 05 06 07 08 09 10; do
    printf "  %-15s" "Taiwan-$i"
    num=$(echo $i | sed 's/^0*//')
    if [ $((num % 5)) -eq 0 ]; then printf "\n"; fi
done
printf "\n\n"

printf "${YELLOW}🇯🇵 日本节点 (10个):${NC}\n"
for i in 01 02 03 04 05 06 07 08 09 10; do
    printf "  %-15s" "Japan-$i"
    num=$(echo $i | sed 's/^0*//')
    if [ $((num % 5)) -eq 0 ]; then printf "\n"; fi
done
printf "\n\n"

printf "${YELLOW}🇸🇬 新加坡节点 (10个):${NC}\n"
for i in 01 02 03 04 05 06 07 08 09 10; do
    printf "  %-15s" "Singapore-$i"
    num=$(echo $i | sed 's/^0*//')
    if [ $((num % 5)) -eq 0 ]; then printf "\n"; fi
done
printf "\n\n"

printf "${YELLOW}🇺🇸 美国节点 (10个):${NC}\n"
for i in 01 02 03 04 05 06 07 08 09 10; do
    printf "  %-15s" "USA-$i"
    num=$(echo $i | sed 's/^0*//')
    if [ $((num % 5)) -eq 0 ]; then printf "\n"; fi
done
printf "\n\n"

printf "${YELLOW}🇬🇧 英国节点 (5个):${NC}\n"
for i in 01 02 03 04 05; do
    printf "  %-15s" "UK-$i"
done
printf "\n\n"

printf "${YELLOW}🇲🇾 马来西亚节点 (5个):${NC}\n"
for i in 01 02 03 04 05; do
    printf "  %-15s" "Malaysia-$i"
done
printf "\n\n"

printf "${YELLOW}🇹🇷 土耳其节点 (2个):${NC}\n"
printf "  Turkey-01      Turkey-02\n"
printf "\n"

printf "${YELLOW}🇦🇷 阿根廷节点 (2个):${NC}\n"
printf "  Argentina-01   Argentina-02\n"
printf "\n"

printf "${CYAN}🤖 智能模式:${NC}\n"
printf "  auto           fallback\n"
printf "\n"

printf "${BLUE}========================================${NC}\n"
printf "${GREEN}使用方法:${NC}\n"
printf "  ${CYAN}./switch_node.sh \"Hong Kong-01\"${NC}  # 切换到香港01节点\n"
printf "  ${CYAN}./switch_node.sh \"Japan-05\"${NC}        # 切换到日本05节点\n"
printf "  ${CYAN}./switch_node.sh \"auto\"${NC}            # 切换到自动模式\n"
printf "${BLUE}========================================${NC}\n"
