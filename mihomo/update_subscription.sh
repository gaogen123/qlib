#!/bin/bash

# 检查是否提供了订阅链接
if [ -z "$1" ]; then
    echo "使用方法: $0 <订阅链接>"
    echo "例如: $0 'https://your-subscription-url.com/sub'"
    echo ""
    echo "或者，您可以在脚本中设置默认订阅链接"
    exit 1
fi

SUBSCRIPTION_URL="$1"
echo "正在下载订阅内容..."
echo "订阅链接: $SUBSCRIPTION_URL"

# 下载订阅内容
curl -s -L "$SUBSCRIPTION_URL" > subscription_raw.txt

if [ -s subscription_raw.txt ]; then
    echo "订阅内容下载成功，正在解析..."
    
    # 尝试base64解码
    base64 -d subscription_raw.txt > subscription_decoded.txt 2>/dev/null
    
    if [ -s subscription_decoded.txt ]; then
        echo "Base64解码成功"
        mv subscription_decoded.txt subscription.yaml
    else
        echo "Base64解码失败，使用原始内容"
        mv subscription_raw.txt subscription.yaml
    fi
    
    echo "订阅文件已更新为 subscription.yaml"
    echo "文件大小: $(wc -c < subscription.yaml) 字节"
    echo "文件行数: $(wc -l < subscription.yaml)"
    
    # 检查文件内容
    echo "文件前几行内容:"
    head -5 subscription.yaml
    
else
    echo "订阅内容下载失败"
    echo "请检查订阅链接是否正确"
    exit 1
fi

# 清理临时文件
rm -f subscription_raw.txt subscription_decoded.txt

echo "订阅更新完成！"
echo "现在可以启动mihomo: ./start.sh"
