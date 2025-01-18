#!/bin/bash

# 检查脚本是否已经下载
if [ ! -f /root/onekey.sh ]; then
  echo "未找到脚本文件，正在下载..."
  wget -O /root/onekey.sh https://github.com/sinian-liu/onekey/raw/main/onekey.sh && chmod +x /root/onekey.sh
fi

# 显示菜单并处理选择
show_menu() {
  echo "请选择要执行的操作："
  echo "1. 安装v2ray脚本"
  echo "2. VPS一键测试脚本"
  echo "3. BBR安装"
  read -p "输入选项：" choice
  case $choice in
    1)
      # 执行安装v2ray脚本
      echo "正在安装v2ray脚本..."
      wget -P /root -N --no-check-certificate "https://raw.githubusercontent.com/sinian-liu/v2ray-agent/master/install.sh" && chmod 700 /root/install.sh && /root/install.sh
      ;;
    2)
      # 执行 VPS 一键测试脚本
      echo "正在执行VPS一键测试脚本..."
      bash <(curl -sL https://raw.githubusercontent.com/sinian-liu/VPStest/main/system_info.sh)
      ;;
    3)
      # 执行 BBR 安装脚本
      echo "正在安装BBR..."
      wget -O tcpx.sh "https://github.com/sinian-liu/Linux-NetSpeed-BBR/raw/master/tcpx.sh" && chmod +x tcpx.sh && ./tcpx.sh
      ;;
    *)
      echo "无效选择，请选择有效的操作编号 (1, 2, 3)"
      ;;
  esac
}

# 允许用户输入 s 来显示菜单
echo "输入 s 启动脚本"
read -p "请输入命令：" user_input

if [ "$user_input" == "s" ]; then
  show_menu
else
  echo "无效的输入，脚本退出。"
fi
