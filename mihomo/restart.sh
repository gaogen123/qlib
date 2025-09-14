#!/bin/bash
cd /root/autodl-tmp/mihomo

echo "正在重启Mihomo..."

# 停止服务
./stop.sh

# 等待进程完全停止
sleep 2

# 启动服务
./start.sh

echo "重启完成！"
