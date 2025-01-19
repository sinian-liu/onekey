#!/bin/bash

# 设置颜色
GREEN="\033[32m"
RED="\033[31m"
YELLOW="\033[33m"
RESET="\033[0m"

# 系统检测函数
check_system() {
    if [ -f /etc/lsb-release ]; then
        # Ubuntu/Debian 系统
        SYSTEM="ubuntu"
    elif [ -f /etc/redhat-release ]; then
        # CentOS 系统
        SYSTEM="centos"
    elif [ -f /etc/fedora-release ]; then
        # Fedora 系统
        SYSTEM="fedora"
    else
        SYSTEM="unknown"
    fi
}

# 系统更新函数
update_system() {
    check_system
    if [ "$SYSTEM" == "ubuntu" ] || [ "$SYSTEM" == "debian" ]; then
        # 对于 Debian/Ubuntu 系统
        echo -e "${GREEN}正在更新 Debian/Ubuntu 系统...${RESET}"
        sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && sudo apt clean
    elif [ "$SYSTEM" == "centos" ]; then
        # 对于 CentOS 系统
        echo -e "${GREEN}正在更新 CentOS 系统...${RESET}"
        sudo yum update -y && sudo yum clean all
    elif [ "$SYSTEM" == "fedora" ]; then
        # 对于 Fedora 系统
        echo -e "${GREEN}正在更新 Fedora 系统...${RESET}"
        sudo dnf update -y && sudo dnf clean all
    else
        echo -e "${RED}无法识别您的操作系统，跳过更新步骤。${RESET}"
    fi
}

# 更新系统
update_system

# 设置快捷命令 s
if ! grep -q "alias s=" ~/.bashrc; then
    echo -e "${GREEN}正在为 s 设置快捷命令...${RESET}"
    echo "alias s='wget -O /root/onekey.sh https://github.com/sinian-liu/onekey/raw/main/onekey.sh && chmod +x /root/onekey.sh && /root/onekey.sh'" >> ~/.bashrc
    source ~/.bashrc
    echo -e "${GREEN}快捷命令 s 已设置。${RESET}"
else
    echo -e "${YELLOW}快捷命令 s 已经存在。${RESET}"
fi

# 提示用户输入选项
echo -e "${GREEN}=============================================${RESET}"
echo -e "${GREEN}服务器推荐：https://my.frantech.ca/aff.php?aff=4337${RESET}"
echo -e "${GREEN}VPS评测官方网站：https://www.1373737.xyz/${RESET}"
echo -e "${GREEN}YouTube频道：https://www.youtube.com/@cyndiboy7881${RESET}"
echo -e "${GREEN}=============================================${RESET}"
echo "请选择要执行的操作："
echo -e "${YELLOW}1. 安装 v2ray 脚本${RESET}"
echo -e "${YELLOW}2. VPS 一键测试脚本${RESET}"
echo -e "${YELLOW}3. BBR 安装脚本${RESET}"
echo -e "${YELLOW}4. 一键永久禁用 IPv6${RESET}"
echo -e "${YELLOW}5. 一键解除禁用 IPv6${RESET}"
echo -e "${YELLOW}6. 无人直播云 SRS 安装${RESET}"
echo -e "${YELLOW}7. 宝塔纯净版安装${RESET}"
echo -e "${YELLOW}8. 长时间保持 SSH 会话连接不断开${RESET}"
echo -e "${YELLOW}9. 重启服务器${RESET}"
echo -e "${GREEN}=============================================${RESET}"
read -p "请输入选项 [1-9]:" option

case $option in
    1)
        # 安装 v2ray 脚本
        echo -e "${GREEN}正在安装 v2ray ...${RESET}"
        wget -P /root -N --no-check-certificate "https://raw.githubusercontent.com/sinian-liu/v2ray-agent-2.5.73/master/install.sh" && chmod 700 /root/install.sh && /root/install.sh
        ;;
    2)
        # VPS 一键测试脚本
        echo -e "${GREEN}正在进行 VPS 测试 ...${RESET}"
        bash <(curl -sL https://raw.githubusercontent.com/sinian-liu/VPStest/main/system_info.sh)
        ;;
    3)
        # BBR 安装脚本
        echo -e "${GREEN}正在安装 BBR ...${RESET}"
        wget -O tcpx.sh "https://github.com/sinian-liu/Linux-NetSpeed-BBR/raw/master/tcpx.sh" && chmod +x tcpx.sh && ./tcpx.sh
        ;;
    4)
        # 永久禁用 IPv6
        echo -e "${GREEN}正在禁用 IPv6 ...${RESET}"
        
        # 检测系统类型（Ubuntu/Debian 或 CentOS/RHEL）
        if [ -f /etc/lsb-release ]; then
            # Ubuntu 或 Debian 系统
            echo -e "${GREEN}禁用 IPv6：${RESET}"
            sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1
            sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1
            echo "net.ipv6.conf.all.disable_ipv6=1" | sudo tee -a /etc/sysctl.conf
            echo "net.ipv6.conf.default.disable_ipv6=1" | sudo tee -a /etc/sysctl.conf
            sudo sysctl -p
        elif [ -f /etc/redhat-release ]; then
            # CentOS 或 RHEL 系统
            echo -e "${GREEN}禁用 IPv6：${RESET}"
            sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1
            sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1
            echo "net.ipv6.conf.all.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.conf
            echo "net.ipv6.conf.default.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.conf
            sudo sysctl -p
        else
            echo -e "${RED}无法识别您的操作系统，无法禁用 IPv6。${RESET}"
        fi
        echo -e "${GREEN}IPv6 已禁用。${RESET}"
        ;;
    5)
        # 解除禁用 IPv6
        echo -e "${GREEN}正在解除禁用 IPv6 ...${RESET}"
        
        # 检测系统类型（Ubuntu/Debian 或 CentOS/RHEL）
        if [ -f /etc/lsb-release ]; then
            # Ubuntu 或 Debian 系统
            echo -e "${GREEN}启用 IPv6：${RESET}"
            sudo sysctl -w net.ipv6.conf.all.disable_ipv6=0
            sudo sysctl -w net.ipv6.conf.default.disable_ipv6=0
            sudo sed -i '/net.ipv6.conf.all.disable_ipv6/d' /etc/sysctl.conf
            sudo sed -i '/net.ipv6.conf.default.disable_ipv6/d' /etc/sysctl.conf
            sudo sysctl -p
        elif [ -f /etc/redhat-release ]; then
            # CentOS 或 RHEL 系统
            echo -e "${GREEN}启用 IPv6：${RESET}"
            sudo sysctl -w net.ipv6.conf.all.disable_ipv6=0
            sudo sysctl -w net.ipv6.conf.default.disable_ipv6=0
            sudo sed -i '/net.ipv6.conf.all.disable_ipv6/d' /etc/sysctl.conf
            sudo sed -i '/net.ipv6.conf.default.disable_ipv6/d' /etc/sysctl.conf
            sudo sysctl -p
        else
            echo -e "${RED}无法识别您的操作系统，无法解除禁用 IPv6。${RESET}"
        fi
        echo -e "${GREEN}IPv6 已解除禁用。${RESET}"
        ;;
    6)
        # 无人直播云 SRS 安装
        echo -e "${GREEN}正在安装无人直播云 SRS ...${RESET}"
        
        # 提示用户输入直播端口号
        read -p "请输入要使用的直播端口号 (默认为1935): " live_port
        live_port=${live_port:-1935}  # 如果没有输入，则使用默认端口1935

        # 提示用户输入管理端口号
        read -p "请输入要使用的管理端口号 (默认为2022): " mgmt_port
        mgmt_port=${mgmt_port:-2022}  # 如果没有输入，则使用默认端口2022

        # 检测端口是否被占用
        check_port() {
            local port=$1
            if netstat -tuln | grep ":$port" > /dev/null; then
                return 1
            else
                return 0
            fi
        }

        # 检查直播端口是否被占用
        check_port $live_port
        if [ $? -eq 1 ]; then
            echo -e "${RED}端口 $live_port 已被占用！${RESET}"
            read -p "请输入其他端口号作为直播端口: " live_port
        fi

        # 检查管理端口是否被占用
        check_port $mgmt_port
        if [ $? -eq 1 ]; then
            echo -e "${RED}端口 $mgmt_port 已被占用！${RESET}"
            read -p "请输入其他端口号作为管理端口: " mgmt_port
        fi

        # 安装 SRS
        bash <(curl -sSL https://github.com/ossrs/srs/releases/download/v5.0.19/srs-5.0.19-linux-x64.tar.gz) --port $live_port --mgmt-port $mgmt_port
        ;;
    7)
        # 宝塔纯净版安装
        echo -e "${GREEN}正在安装宝塔面板...${RESET}"
        if [ -f /etc/lsb-release ]; then
            # Ubuntu 或 Debian 系统
            wget -O install.sh https://install.baota.sbs/install/install_6.0.sh && bash install.sh
        elif [ -f /etc/redhat-release ]; then
            # CentOS 系统
            yum install -y wget && wget -O install.sh https://install.baota.sbs/install/install_6.0.sh && sh install.sh
        else
            echo -e "${RED}无法识别您的操作系统，无法安装宝塔面板。${RESET}"
        fi
        ;;
    8)
        # 长时间保持 SSH 会话连接不断开
        echo -e "${GREEN}正在配置 SSH 保持连接...${RESET}"
        read -p "请输入每次心跳请求的间隔时间（单位：分钟，默认为5分钟）： " interval
        interval=${interval:-5}  # 默认值为5分钟
        read -p "请输入客户端最大无响应次数（默认为50次）： " max_count
        max_count=${max_count:-50}  # 默认值为50次
        interval_seconds=$((interval * 60))

        # 修改 /etc/ssh/sshd_config 配置文件
        echo "正在更新 SSH 配置文件..."
        sudo sed -i "/^ClientAliveInterval/c\ClientAliveInterval $interval_seconds" /etc/ssh/sshd_config
        sudo sed -i "/^ClientAliveCountMax/c\ClientAliveCountMax $max_count" /etc/ssh/sshd_config

        # 重启 SSH 服务
        echo "正在重启 SSH 服务以应用配置..."
        sudo systemctl restart sshd

        echo -e "${GREEN}配置完成！心跳请求间隔为 $interval 分钟，最大无响应次数为 $max_count。${RESET}"
        ;;
    9)
        # 重启服务器
        echo -e "${GREEN}正在重启服务器...${RESET}"
        sudo reboot
        ;;
    *)
        echo -e "${RED}无效的选项，请重新选择！${RESET}"
        ;;
esac
