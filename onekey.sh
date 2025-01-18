#!/bin/bash

# 检查是否已经启动过脚本，记录一个标志文件
FLAG_FILE="/root/onekey_installed.flag"

# 检查系统类型并安装依赖
install_dependencies() {
  echo "正在检测系统类型..."

  if [ -f /etc/debian_version ]; then
    OS="Debian"
  elif [ -f /etc/centos-release ]; then
    OS="CentOS"
  elif [ -f /etc/lsb-release ] && grep -iq "Ubuntu" /etc/lsb-release; then
    OS="Ubuntu"
  else
    echo "不支持的系统类型，请使用 Debian、CentOS 或 Ubuntu 系统。"
    exit 1
  fi

  echo "系统类型: $OS"

  # 安装必要依赖（以 Debian/Ubuntu 为例）
  if [ "$OS" == "Debian" ] || [ "$OS" == "Ubuntu" ]; then
    echo "检测到 Debian/Ubuntu，正在安装依赖..."
    apt update && apt install -y wget curl bash
  # 安装 CentOS 依赖
  elif [ "$OS" == "CentOS" ]; then
    echo "检测到 CentOS，正在安装依赖..."
    yum update -y && yum install -y wget curl bash
  fi
}

# 提供功能选择
if [ ! -f "$FLAG_FILE" ]; then
  # 如果是第一次运行，执行系统检测和安装依赖
  install_dependencies
  # 创建标志文件，表示脚本已经执行过
  touch "$FLAG_FILE"
fi

echo "请选择要执行的操作："
echo "1. 安装v2ray脚本"
echo "2. VPS一键测试脚本"
echo "3. BBR安装"
echo "输入 s 启动脚本"

# 读取用户输入
read -n 1 choice
echo ""

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
    # 启动的其他脚本命令放这里
    ;;
  *)
    echo "无效的输入，请重新运行脚本并选择正确的数字。"
    ;;
esac
