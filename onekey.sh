#!/bin/bash

# 模拟 alias s 命令，直接在当前脚本中执行
function show_menu() {
    clear
    echo "请选择要执行的操作："
    echo "1. 安装v2ray脚本"
    echo "2. VPS一键测试脚本"
    echo "3. BBR安装"
    echo "输入 s 启动此脚本"
    echo -n "输入选项: "
    read option
    case $option in
        1)
            echo "安装v2ray脚本"
            # 在这里添加安装 v2ray 脚本的代码
            ;;
        2)
            echo "VPS一键测试脚本"
            # 在这里添加 VPS 测试脚本的代码
            ;;
        3)
            echo "BBR安装"
            # 在这里添加 BBR 安装脚本的代码
            ;;
        s)
            echo "正在启动此脚本..."
            # 重新执行当前脚本
            bash /root/onekey.sh
            ;;
        *)
            echo "无效选择，请选择有效的操作编号 (1, 2, 3)"
            ;;
    esac
}

# 如果是第一次执行脚本，设置快捷命令 `s`
if ! type s &>/dev/null; then
    echo "没有找到快捷命令 's'，将模拟它..."
    # 使用 s 来调用当前脚本
    alias s='bash /root/onekey.sh'
fi

# 显示菜单
show_menu
