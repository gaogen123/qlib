#!/bin/bash
echo "=== Mihomo 状态检查 ==="
echo "进程状态:"
ps aux | grep mihomo | grep -v grep
echo ""
echo "端口监听状态:"
# 尝试多种方法检测端口7890的监听状态
PORT=7890
PORT_LISTENING=false

# 方法1: 使用ss命令（现代系统推荐）
if command -v ss >/dev/null 2>&1; then
    if ss -tlnp | grep ":$PORT " >/dev/null 2>&1; then
        echo "端口 $PORT 正在监听 (ss检测)"
        ss -tlnp | grep ":$PORT "
        PORT_LISTENING=true
    fi
fi

# 方法2: 使用netstat命令（传统方法）
if [ "$PORT_LISTENING" = false ] && command -v netstat >/dev/null 2>&1; then
    if netstat -tlnp 2>/dev/null | grep ":$PORT " >/dev/null 2>&1; then
        echo "端口 $PORT 正在监听 (netstat检测)"
        netstat -tlnp 2>/dev/null | grep ":$PORT "
        PORT_LISTENING=true
    fi
fi

# 方法3: 使用lsof命令
if [ "$PORT_LISTENING" = false ] && command -v lsof >/dev/null 2>&1; then
    if lsof -i :$PORT >/dev/null 2>&1; then
        echo "端口 $PORT 正在监听 (lsof检测)"
        lsof -i :$PORT
        PORT_LISTENING=true
    fi
fi

# 方法4: 使用/proc/net/tcp检查
if [ "$PORT_LISTENING" = false ]; then
    PORT_HEX=$(printf "%04X" $PORT)
    if grep -q ":$PORT_HEX " /proc/net/tcp 2>/dev/null; then
        echo "端口 $PORT 正在监听 (/proc/net/tcp检测)"
        grep ":$PORT_HEX " /proc/net/tcp
        PORT_LISTENING=true
    fi
fi

# 如果所有方法都未检测到端口监听
if [ "$PORT_LISTENING" = false ]; then
    echo "端口 $PORT 未监听"
fi

echo ""
echo "配置文件:"
ls -la config.yaml
echo ""
echo "可执行文件:"
ls -la mihomo
