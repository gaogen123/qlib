#!/bin/bash

# Mihomo 代理测试脚本

echo "=== Mihomo 代理测试 ==="
echo ""

# 检查mihomo进程
echo "1. 检查mihomo进程状态:"
if pgrep -f "mihomo -f config.yaml" > /dev/null; then
    echo "   ✅ mihomo正在运行 (PID: $(pgrep -f 'mihomo -f config.yaml'))"
else
    echo "   ❌ mihomo未运行"
    exit 1
fi

# 检查端口监听
echo ""
echo "2. 检查端口监听状态:"
if netstat -tlnp 2>/dev/null | grep -q ":7890"; then
    echo "   ✅ 端口7890正在监听"
else
    echo "   ❌ 端口7890未监听"
fi

# 检查当前选择的节点
echo ""
echo "3. 检查当前选择的节点:"
CURRENT_NODE=$(curl -s "http://127.0.0.1:9090/proxies/PROXY" 2>/dev/null | grep -o '"now":"[^"]*"' | cut -d'"' -f4)
if [ -n "$CURRENT_NODE" ]; then
    echo "   ✅ 当前节点: $CURRENT_NODE"
else
    echo "   ❌ 无法获取当前节点信息"
fi

# 测试代理连接
echo ""
echo "4. 测试代理连接:"
echo "   正在测试通过代理访问httpbin.org..."
RESPONSE=$(timeout 15 curl -s --proxy http://127.0.0.1:7890 "http://httpbin.org/ip" 2>/dev/null)
if [ $? -eq 0 ] && [ -n "$RESPONSE" ]; then
    echo "   ✅ 代理连接成功"
    echo "   响应内容: $RESPONSE"
else
    echo "   ⚠️  代理连接可能有问题（超时或失败）"
fi

# 检查配置模式
echo ""
echo "5. 检查配置模式:"
if grep -q "mode: global" config.yaml; then
    echo "   ✅ 已启用全局模式"
else
    echo "   ❌ 未启用全局模式"
fi

echo ""
echo "=== 测试完成 ==="
echo ""
echo "代理配置信息:"
echo "- 代理地址: 127.0.0.1:7890"
echo "- 管理界面: http://127.0.0.1:9090/ui/"
echo "- 当前节点: $CURRENT_NODE"
echo "- 运行模式: 全局模式"
echo ""
echo "使用方法:"
echo "export http_proxy=http://127.0.0.1:7890"
echo "export https_proxy=http://127.0.0.1:7890"
echo "export HTTP_PROXY=http://127.0.0.1:7890"
echo "export HTTPS_PROXY=http://127.0.0.1:7890"
