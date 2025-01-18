#!/bin/bash

# 设置 s 快捷命令，如果还没有设置
if ! grep -q "alias s=" ~/.bashrc; then
    echo "正在为 s 设置快捷命令..."
    echo "alias s='bash /root/onekey.sh'" >> ~/.bashrc
    source ~/.bashrc
    echo "快捷命令 s 已设置。"
else
    echo "快捷命令 s 已经存在。"
fi

# 显示菜单并选择操作
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
        # 在这里添加 v2ray 安装脚本的代码
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
