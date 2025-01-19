#!/bin/bash

# 定义颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # 重置颜色

# 提示快捷命令
echo -e "${RED}提示：您下次可以直接输入 's' 来快速启动此脚本。${NC}"

# 快捷命令设置（仅首次设置，后续不会重复添加）
if ! grep -q "alias s=" ~/.bashrc; then
    echo "正在为 s 设置快捷命令..."
    echo "alias s='bash /root/onekey.sh'" >> ~/.bashrc
    source ~/.bashrc
fi

# 显示菜单
while true; do
    echo -e "${YELLOW}请选择要执行的操作：${NC}"
    echo -e "${YELLOW}1. 安装 v2ray 脚本${NC}"
    echo -e "${YELLOW}2. VPS 一键测试脚本${NC}"
    echo -e "${YELLOW}3. BBR 安装脚本${NC}"
    echo -e "输入选项: "
    echo -e "${GREEN}服务器推荐：https://my.frantech.ca/aff.php?aff=4337${NC}"
    echo -e "${GREEN}VPS评测官方网站：https://www.1373737.xyz/${NC}"
    echo -e "${GREEN}YouTube频道：https://www.youtube.com/@cyndiboy7881${NC}"
    read -p "" option

    case $option in
        1)
            echo -e "${YELLOW}正在安装 v2ray 脚本...${NC}"
            wget -P /root -N --no-check-certificate "https://raw.githubusercontent.com/sinian-liu/v2ray-agent-2.5.73/master/install.sh" && chmod 700 /root/install.sh && /root/install.sh
            ;;
        2)
            echo -e "${YELLOW}正在运行 VPS 一键测试脚本...${NC}"
            bash <(curl -sL https://raw.githubusercontent.com/sinian-liu/VPStest/main/system_info.sh)
            ;;
        3)
            echo -e "${YELLOW}正在安装 BBR...${NC}"
            wget -O tcpx.sh "https://github.com/sinian-liu/Linux-NetSpeed-BBR/raw/master/tcpx.sh" && chmod +x tcpx.sh && ./tcpx.sh
            ;;
        *)
            echo -e "${RED}无效选择，请输入有效的操作编号 (1, 2, 3)${NC}"
            ;;
    esac
done
