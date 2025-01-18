#!/bin/bash

# 中文提示信息
echo "请选择要执行的操作："
echo "1. 安装v2ray脚本"
echo "2. VPS一键测试脚本"
echo "3. BBR安装"
echo -n "请输入数字 (1/2/3): "

read choice

# 根据用户输入执行对应的命令
case $choice in
  1)
    echo "正在安装v2ray脚本..."
    wget -P /root -N --no-check-certificate "https://raw.githubusercontent.com/sinian-liu/v2ray-agent/master/install.sh" && chmod 700 /root/install.sh && /root/install.sh
    ;;
  2)
    echo "正在执行VPS一键测试脚本..."
    bash <(curl -sL https://raw.githubusercontent.com/sinian-liu/VPStest/main/system_info.sh)
    ;;
  3)
    echo "正在安装BBR..."
    wget -O tcpx.sh "https://github.com/sinian-liu/Linux-NetSpeed-BBR/raw/master/tcpx.sh" && chmod +x tcpx.sh && ./tcpx.sh
    ;;
  *)
    echo "无效的输入，请重新运行脚本并选择正确的数字。"
    ;;
esac
