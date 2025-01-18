#!/bin/bash

# 增加s为快捷启动命令，检查并创建 alias（如果没有的话）
if ! grep -q "alias s=" ~/.bashrc; then
    echo "正在为 s 设置快捷命令..."
    echo "alias s='bash /root/onekey.sh'" >> ~/.bashrc
    source ~/.bashrc
    echo "快捷命令 s 已设置。"
else
    echo "快捷命令 s 已经存在。"
fi

# 显示菜单
display_menu() {
    clear
    echo "请选择要执行的操作："
    echo "1. 安装v2ray脚本"
    echo "2. VPS一键测试脚本"
    echo "3. BBR安装"
    echo "输入s启动此脚本"
}

# 执行相应的操作
execute_option() {
    case $1 in
        1)
            echo "正在安装v2ray脚本..."
            wget -P /root -N --no-check-certificate "https://raw.githubusercontent.com/sinian-liu/v2ray-agent/master/install.sh" && chmod 700 /root/install.sh && /root/install.sh
            ;;
        2)
            echo "正在运行VPS一键测试脚本..."
            bash <(curl -sL https://raw.githubusercontent.com/sinian-liu/VPStest/main/system_info.sh)
            ;;
        3)
            echo "正在安装BBR..."
            wget -O tcpx.sh "https://github.com/sinian-liu/Linux-NetSpeed-BBR/raw/master/tcpx.sh" && chmod +x tcpx.sh && ./tcpx.sh
            ;;
        *)
            echo "无效选择，请选择有效的操作编号 (1, 2, 3)"
            ;;
    esac
}

# 检查并创建快捷命令的 alias
check_and_create_alias() {
    if ! grep -q "alias s=" ~/.bashrc; then
        echo "正在为 s 设置快捷命令..."
        echo "alias s='bash /root/onekey.sh'" >> ~/.bashrc
        source ~/.bashrc
        echo "快捷命令 s 已设置。"
    else
        echo "快捷命令 s 已经存在。"
    fi
}

# 主程序
if [ $# -eq 0 ]; then
    # 如果没有提供参数，显示菜单
    display_menu
    read -p "输入选项: " choice
    execute_option $choice
else
    # 如果提供了参数，直接执行对应的操作
    execute_option $1
fi
