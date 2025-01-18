#!/bin/bash

# 检查并赋予执行权限
if [ ! -x "/root/onekey.sh" ]; then
    echo "脚本没有执行权限，正在赋予执行权限..."
    chmod +x /root/onekey.sh
else
    echo "脚本已有执行权限。"
fi

# 检测系统类型并安装必要的依赖
echo "正在检测系统类型..."
if [ -f /etc/os-release ]; then
    source /etc/os-release
    OS=$NAME
else
    echo "无法检测到系统类型。"
    exit 1
fi

# 安装依赖或更新系统
echo "检测到系统类型：$OS"
case $OS in
    "Ubuntu" | "Debian")
        echo "正在更新系统和安装必需的依赖..."
        apt update && apt upgrade -y
        apt install -y curl wget bash
        ;;
    "CentOS" | "Rocky Linux" | "AlmaLinux")
        echo "正在更新系统和安装必需的依赖..."
        yum update -y
        yum install -y curl wget bash
        ;;
    *)
        echo "未支持的操作系统类型：$OS"
        exit 1
        ;;
esac

# 提示用户输入选择
echo "请选择要执行的操作："
echo "1. 安装v2ray脚本"
echo "2. VPS一键测试脚本"
echo "3. BBR安装"
echo "输入 s 启动脚本"
echo -n "请输入选择 (1/2/3/s): "

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
  s)
    echo "启动脚本..."
    /root/onekey.sh
    ;;
  *)
    echo "无效的输入，请重新运行脚本并选择正确的数字。"
    ;;
esac
