#!/bin/bash
cd /root/autodl-tmp/mihomo

# 检查是否已经在运行
if pgrep -f "mihomo -f config.yaml" > /dev/null; then
    echo "Mihomo已经在运行中"
    ./status.sh
    exit 0
fi

# 检查配置文件是否存在
if [ ! -f "config.yaml" ]; then
    echo "错误: 配置文件 config.yaml 不存在"
    exit 1
fi

# 检查订阅文件是否存在
if [ ! -f "subscription.yaml" ]; then
    echo "警告: 订阅文件 subscription.yaml 不存在"
    echo "请先运行: ./update_subscription.sh <您的订阅链接>"
    exit 1
fi

echo "正在启动Mihomo..."
# 在后台启动mihomo
nohup ./mihomo -f config.yaml > mihomo.log 2>&1 &

# 等待一下让进程启动
sleep 2

# 检查是否启动成功
if pgrep -f "mihomo -f config.yaml" > /dev/null; then
    echo "Mihomo启动成功！"
    echo "进程ID: $(pgrep -f 'mihomo -f config.yaml')"
    echo "日志文件: mihomo.log"
    echo "代理端口: 7890"
    echo ""
    ./status.sh
else
    echo "Mihomo启动失败，请检查日志文件 mihomo.log"
    exit 1
fi
