#!/bin/bash

echo "=== Mihomo 代理工具设置向导 ==="
echo ""

# 检查mihomo程序是否存在
if [ ! -f "./mihomo" ]; then
    echo "错误: mihomo程序不存在"
    exit 1
fi

# 检查配置文件是否存在
if [ ! -f "config.yaml" ]; then
    echo "错误: 配置文件不存在"
    exit 1
fi

echo "1. 检查当前配置..."
echo "配置文件: config.yaml"
echo "代理端口: 7890"
echo ""

# 询问订阅链接
echo "2. 配置订阅链接"
echo "请输入您的订阅链接 (例如: https://your-subscription.com/sub):"
read -p "订阅链接: " SUBSCRIPTION_URL

if [ -z "$SUBSCRIPTION_URL" ]; then
    echo "错误: 订阅链接不能为空"
    exit 1
fi

echo ""
echo "正在更新订阅..."
./update_subscription.sh "$SUBSCRIPTION_URL"

if [ $? -eq 0 ]; then
    echo ""
    echo "3. 启动代理服务..."
    ./start.sh
    
    echo ""
    echo "=== 设置完成 ==="
    echo "代理服务已启动，端口: 7890"
    echo "您可以在浏览器或应用程序中配置代理:"
    echo "  - 代理类型: HTTP/SOCKS5"
    echo "  - 代理地址: 127.0.0.1"
    echo "  - 代理端口: 7890"
    echo ""
    echo "管理命令:"
    echo "  - 查看状态: ./status.sh"
    echo "  - 停止服务: ./stop.sh"
    echo "  - 重启服务: ./restart.sh"
    echo "  - 更新订阅: ./update_subscription.sh <新链接>"
else
    echo "订阅更新失败，请检查链接是否正确"
    exit 1
fi
