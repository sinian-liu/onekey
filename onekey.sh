#!/bin/bash

# 显示菜单
function show_menu() {
    clear
    echo "请选择要执行的操作："
    echo "1. 安装 v2ray 脚本"
    echo "2. VPS 一键测试脚本"
    echo "3. BBR 安装脚本"
    echo -n "输入选项: "
    read -r option
    case $option in
        1)
            echo "正在安装 v2ray 脚本..."
            wget -P /root -N --no-check-certificate "https://raw.githubusercontent.com/sinian-liu/v2ray-agent-2.5.73/master/install.sh" && chmod 700 /root/install.sh && /root/install.sh
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
            echo "无效选择，请输入有效的操作编号 (1, 2, 3)"
            ;;
    esac
}

# 检查并设置快捷命令 s
if ! grep -q "alias s=" ~/.bashrc; then
    echo "alias s='bash /root/onekey.sh'" >> ~/.bashrc
    source ~/.bashrc
    echo "快捷命令 S 已设置。您可以直接输入 's' 来启动脚本。"
else
    echo "快捷命令 S 已存在。输入 's' 启动脚本。"
fi

# 提示用户输入 S 启动脚本
echo "提示：输入 's' 启动此脚本。"

# 运行菜单
show_menu
