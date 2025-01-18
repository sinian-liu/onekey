#!/bin/bash

echo "请选择要执行的操作:"
echo "1. 安装 V2Ray 脚本"
echo "2. VPS 一键测试脚本"
echo "3. 安装 BBR"
read -p "请输入数字 (1-3): " choice

case $choice in
  1)
    echo "正在安装 V2Ray 脚本..."
    wget -P /root -N --no-check-certificate "https://raw.githubusercontent.com/sinian-liu/v2ray-agent/master/install.sh" && chmod 700 /root/install.sh && /root/install.sh
    ;;
  2)
    echo "正在运行 VPS 一键测试脚本..."
    bash <(curl -sL https://raw.githubusercontent.com/sinian-liu/VPStest/main/system_info.sh)
    ;;
  3)
    echo "正在安装 BBR..."
    wget -O tcpx.sh "https://github.com/sinian-liu/Linux-NetSpeed-BBR/raw/master/tcpx.sh" && chmod +x tcpx.sh && ./tcpx.sh
    ;;
  *)
    echo "无效输入，请输入数字 1、2 或 3。"
    ;;
esac
