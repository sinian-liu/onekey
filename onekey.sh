#!/bin/bash

# 检测并安装所需的命令
install_dependencies() {
  echo "正在检查系统依赖..."
  
  # 检查并安装wget
  if ! command -v wget &>/dev/null; then
    echo "未找到 wget，正在安装..."
    if [[ -f /etc/debian_version ]]; then
      apt-get update && apt-get install -y wget
    elif [[ -f /etc/redhat-release ]]; then
      yum install -y wget
    else
      echo "不支持的操作系统"
      exit 1
    fi
  fi

  # 检查并安装curl
  if ! command -v curl &>/dev/null; then
    echo "未找到 curl，正在安装..."
    if [[ -f /etc/debian_version ]]; then
      apt-get install -y curl
    elif [[ -f /etc/redhat-release ]]; then
      yum install -y curl
    else
      echo "不支持的操作系统"
      exit 1
    fi
  fi
}

# 检测系统类型
detect_os() {
  if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    OS=$NAME
    VERSION=$VERSION_ID
    echo "系统类型: $OS $VERSION"
  else
    echo "无法检测系统类型"
    exit 1
  fi
}

# 提示信息并执行命令
run_script() {
  echo "请选择要执行的操作："
  echo "1. 安装v2ray脚本"
  echo "2. VPS一键测试脚本"
  echo "3. BBR安装"
  echo "s. 运行自定义命令"
  echo -n "请输入数字 (1/2/3/s): "

  read choice

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
      echo -n "请输入要运行的命令: "
      read custom_command
      echo "正在运行自定义命令: $custom_command"
      $custom_command
      ;;
    *)
      echo "无效的输入，请重新运行脚本并选择正确的数字。"
      ;;
  esac
}

# 主程序
install_dependencies
detect_os
run_script
