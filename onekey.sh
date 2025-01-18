#!/bin/bash

# 检查脚本是否已经存在
if [ ! -f /usr/local/bin/onekey ]; then
    echo "脚本未安装，正在安装..."
    # 下载脚本并设置权限
    wget -O /usr/local/bin/onekey https://github.com/sinian-liu/onekey/raw/main/onekey.sh
    chmod +x /usr/local/bin/onekey
    # 创建快捷命令 s
    ln -s /usr/local/bin/onekey /usr/local/bin/s
    echo "安装完成，您可以通过输入 's' 来启动脚本"
    exit 0
fi

# 如果脚本已经安装，显示菜单并等待用户选择
echo "请选择要执行的操作："
echo "1. 安装v2ray脚本"
echo "2. VPS一键测试脚本"
echo "3. BBR安装"
echo "输入 's' 启动脚本"

# 提示用户输入命令
read -p "请输入命令：" user_input

# 如果输入的是 s，则启动脚本
if [ "$user_input" == "s" ]; then
    echo "启动脚本..."
    bash /usr/local/bin/onekey
else
    echo "无效选择，请选择有效的操作编号 (1, 2, 3)"
    exit 1
fi
