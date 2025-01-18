#!/bin/bash

# 检查脚本是否已经安装
if [ ! -f /usr/local/bin/onekey ]; then
    echo "脚本未安装，正在安装..."
    # 下载脚本并设置权限
    wget -O /usr/local/bin/onekey https://github.com/sinian-liu/onekey/raw/main/onekey.sh
    chmod +x /usr/local/bin/onekey
    echo "安装完成，您可以通过输入 's' 来启动脚本"
    exit 0
fi

# 主菜单
function show_menu() {
    clear
    echo "请选择要执行的操作："
    echo "1. 安装v2ray脚本"
    echo "2. VPS一键测试脚本"
    echo "3. BBR安装"
    echo "输入 's' 启动脚本"
}

# 执行操作
function execute_option() {
    read -p "请输入命令：" user_input

    case $user_input in
        1)
            echo "开始安装 v2ray 脚本..."
            bash /usr/local/bin/onekey
            ;;
        2)
            echo "开始执行 VPS 一键测试脚本..."
            # 执行 VPS 一键测试脚本的命令
            ;;
        3)
            echo "开始安装 BBR..."
            # 执行 BBR 安装脚本的命令
            ;;
        s)
            show_menu
            execute_option
            ;;
        *)
            echo "无效选择，请选择有效的操作编号 (1, 2, 3)"
            ;;
    esac
}

# 运行主菜单和选择操作
show_menu
execute_option
