#!/bin/bash

# 定义颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # 重置颜色

# 提示快捷命令
echo -e "${RED}提示：您下次可以直接输入 's' 来快速启动此脚本。${NC}"

# 分隔线
echo -e "${YELLOW}=============================================${NC}"

# 显示服务器推荐、评测官网和 YouTube 频道
echo -e "${GREEN}服务器推荐：https://my.frantech.ca/aff.php?aff=4337${NC}"
echo -e "${GREEN}VPS评测官方网站：https://www.1373737.xyz/${NC}"
echo -e "${GREEN}YouTube频道：https://www.youtube.com/@cyndiboy7881${NC}"

# 分隔线
echo -e "${YELLOW}=============================================${NC}"

# 显示菜单
echo -e "${YELLOW}请选择要执行的操作：${NC}"
echo -e "${YELLOW}1. 安装 v2ray 脚本${NC}"
echo -e "${YELLOW}2. VPS 一键测试脚本${NC}"
echo -e "${YELLOW}3. BBR 安装脚本${NC}"
echo -e "${YELLOW}4. 一键永久禁用 IPv6${NC}"
echo -e "${YELLOW}5. 一键解除禁用 IPv6${NC}"
echo -e "${YELLOW}6. KVM 安装 Windows 2003${NC}"
echo -e "${YELLOW}7. 宝塔纯净版安装${NC}"
echo -e "${YELLOW}8. 重启服务器${NC}"
echo -e "输入选项: "

# 读取用户输入并处理
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
    4)
        # 自动检测系统类型
        OS=$(awk -F= '/^ID=/ { print $2 }' /etc/os-release | tr -d '"')
        
        if [[ "$OS" == "ubuntu" || "$OS" == "debian" ]]; then
            echo -e "${YELLOW}适用于 Ubuntu/Debian 系统，正在禁用 IPv6...${NC}"
            sudo bash -c 'echo -e "net.ipv6.conf.all.disable_ipv6 = 1\nnet.ipv6.conf.default.disable_ipv6 = 1\nnet.ipv6.conf.lo.disable_ipv6 = 1" >> /etc/sysctl.conf && sysctl -p'
        elif [[ "$OS" == "centos" ]]; then
            echo -e "${YELLOW}适用于 CentOS 系统，正在禁用 IPv6...${NC}"
            sudo bash -c 'echo -e "net.ipv6.conf.all.disable_ipv6 = 1\nnet.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf && sysctl -p'
        else
            echo -e "${RED}无法识别的操作系统，无法禁用 IPv6。${NC}"
        fi
        ;;
    5)
        # 自动检测系统类型
        OS=$(awk -F= '/^ID=/ { print $2 }' /etc/os-release | tr -d '"')
        
        if [[ "$OS" == "ubuntu" || "$OS" == "debian" ]]; then
            echo -e "${YELLOW}适用于 Ubuntu/Debian 系统，正在解除禁用 IPv6...${NC}"
            sudo sed -i '/disable_ipv6/s/1/0/' /etc/sysctl.conf && sudo sysctl -p && sudo systemctl restart networking
        elif [[ "$OS" == "centos" ]]; then
            echo -e "${YELLOW}适用于 CentOS 系统，正在解除禁用 IPv6...${NC}"
            sudo sed -i '/disable_ipv6/s/1/0/' /etc/sysctl.conf && sudo sysctl -p && sudo systemctl restart network
        else
            echo -e "${RED}无法识别的操作系统，无法解除禁用 IPv6。${NC}"
        fi
        ;;
    6)
        # 自动检测系统类型并安装必要依赖
        OS=$(awk -F= '/^ID=/ { print $2 }' /etc/os-release | tr -d '"')
        
        if [[ "$OS" == "ubuntu" || "$OS" == "debian" ]]; then
            echo -e "${YELLOW}适用于 Debian/Ubuntu 系统，正在安装 KVM 和 Windows 2003...${NC}"
            sudo apt-get install -y xz-utils openssl gawk file wget screen
            screen -S os
            wget --no-check-certificate -O NewReinstall.sh https://git.io/newbetags && chmod a+x NewReinstall.sh && bash NewReinstall.sh
        elif [[ "$OS" == "centos" || "$OS" == "redhat" ]]; then
            echo -e "${YELLOW}适用于 CentOS/RedHat 系统，正在安装 KVM 和 Windows 2003...${NC}"
            sudo yum install -y xz openssl gawk file glibc-common wget screen
            screen -S os
            wget --no-check-certificate -O NewReinstall.sh https://git.io/newbetags && chmod a+x NewReinstall.sh && bash NewReinstall.sh
        else
            echo -e "${RED}无法识别的操作系统，无法安装 KVM 和 Windows 2003。${NC}"
        fi
        ;;
    7)
        # 宝塔纯净版安装
        OS=$(awk -F= '/^ID=/ { print $2 }' /etc/os-release | tr -d '"')
        
        if [[ "$OS" == "ubuntu" || "$OS" == "debian" ]]; then
            echo -e "${YELLOW}适用于 Ubuntu/Debian 系统，正在安装宝塔纯净版...${NC}"
            wget -O install.sh https://install.baota.sbs/install/install_6.0.sh && bash install.sh
        elif [[ "$OS" == "centos" ]]; then
            echo -e "${YELLOW}适用于 CentOS 系统，正在安装宝塔纯净版...${NC}"
            yum install -y wget && wget -O install.sh https://install.baota.sbs/install/install_6.0.sh && sh install.sh
        else
            echo -e "${RED}无法识别的操作系统，无法安装宝塔纯净版。${NC}"
        fi
        ;;
    8)
        # 重启服务器
        echo -e "${YELLOW}正在重启服务器...${NC}"
        sudo reboot
        ;;
    *)
        echo -e "${RED}无效选择，请输入有效的操作编号 (1, 2, 3, 4, 5, 6, 7, 8)${NC}"
        ;;
esac
