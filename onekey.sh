#!/bin/bash

# 检查是否已经设置快捷命令 s
if ! grep -q "alias s=" ~/.bashrc; then
    echo "正在为 s 设置快捷命令..."
    # 创建 alias，设置快捷命令为执行当前脚本
    echo "alias s='bash /root/onekey.sh'" >> ~/.bashrc
    source ~/.bashrc
    echo "快捷命令 s 已设置。"
else
    echo "快捷命令 s 已经存在。"
fi

# 开始显示菜单和执行操作
echo "请输入命令：s"
echo "请选择要执行的操作："
echo "1. 安装v2ray脚本"
echo "2. VPS一键测试脚本"
echo "3. BBR安装"
echo -n "输入选项: "
read choice

case $choice in
    1)
        echo "正在安装 v2ray..."
        # 安装 v2ray 脚本的命令
        ;;
    2)
        echo "正在进行 VPS 测试..."
        # VPS 测试脚本的命令
        ;;
    3)
        echo "正在安装 BBR..."
        # BBR 安装命令
        ;;
    *)
        echo "无效选择，请选择有效的操作编号 (1, 2, 3)"
        ;;
esac
