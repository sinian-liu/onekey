#!/bin/bash

clear
echo -e "\033[1;32m请输入选项并按回车键：\033[0m"
echo -e "\033[1;33m1. 安装 v2ray 脚本\033[0m"
echo -e "\033[1;33m2. VPS 一键测试脚本\033[0m"
echo -e "\033[1;33m3. BBR 安装脚本\033[0m"
echo -e "\033[1;33m4. 一键永久禁用 IPv6\033[0m"
echo -e "\033[1;33m5. 一键解除禁用 IPv6\033[0m"
echo -e "\033[1;33m6. KVM 安装 Windows 2003\033[0m"
echo -e "\033[1;33m7. 宝塔纯净版安装\033[0m"
echo -e "\033[1;33m8. 重启服务器\033[0m"
echo -e "\033[1;33m请输入对应的数字：\033[0m"
read -p "输入选项: " option

case $option in
    1)
        # 安装 v2ray 脚本
        wget -O /root/install-v2ray.sh https://raw.githubusercontent.com/v2ray/v2ray-core/master/release/install.sh && bash /root/install-v2ray.sh
        ;;
    2)
        # VPS 一键测试脚本
        wget -O /root/vps-test.sh https://github.com/sinian-liu/VPStest/raw/main/system_info.sh && chmod +x /root/vps-test.sh && bash /root/vps-test.sh
        ;;
    3)
        # BBR 安装脚本
        wget -O /root/bbr.sh https://github.com/sinian-liu/Linux-NetSpeed-BBR/raw/master/tcpx.sh && chmod +x /root/bbr.sh && bash /root/bbr.sh
        ;;
    4)
        # 永久禁用 IPv6
        if [ -f /etc/debian_version ]; then
            echo "检测到系统为 Debian/Ubuntu"
            sudo bash -c 'echo -e "net.ipv6.conf.all.disable_ipv6 = 1\nnet.ipv6.conf.default.disable_ipv6 = 1\nnet.ipv6.conf.lo.disable_ipv6 = 1" >> /etc/sysctl.conf && sysctl -p'
        elif [ -f /etc/redhat-release ]; then
            echo "检测到系统为 RedHat/CentOS"
            sudo bash -c 'echo -e "net.ipv6.conf.all.disable_ipv6 = 1\nnet.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf && sysctl -p'
        else
            echo "不支持的系统类型。仅支持 Debian/Ubuntu 或 RedHat/CentOS 系统。"
        fi
        ;;
    5)
        # 解除禁用 IPv6
        if [ -f /etc/debian_version ]; then
            echo "检测到系统为 Debian/Ubuntu"
            sudo sed -i '/disable_ipv6/s/1/0/' /etc/sysctl.conf && sudo sysctl -p && sudo systemctl restart networking
        elif [ -f /etc/redhat-release ]; then
            echo "检测到系统为 RedHat/CentOS"
            sudo sed -i '/disable_ipv6/s/1/0/' /etc/sysctl.conf && sudo sysctl -p && sudo systemctl restart network
        else
            echo "不支持的系统类型。仅支持 Debian/Ubuntu 或 RedHat/CentOS 系统。"
        fi
        ;;
    6)
        # KVM 安装 Windows 2003 脚本
        if [ -f /etc/debian_version ]; then
            # Debian/Ubuntu 系统
            echo "检测到系统为 Debian/Ubuntu"
            apt-get install -y xz-utils openssl gawk file wget screen && screen -S os
            apt update -y && apt dist-upgrade -y
            wget --no-check-certificate -O NewReinstall.sh https://git.io/newbetags && chmod a+x NewReinstall.sh && bash NewReinstall.sh
        elif [ -f /etc/redhat-release ]; then
            # RedHat/CentOS 系统
            echo "检测到系统为 RedHat/CentOS"
            yum install -y xz openssl gawk file glibc-common wget screen && screen -S os
            wget --no-check-certificate -O NewReinstall.sh https://git.io/newbetags && chmod a+x NewReinstall.sh && bash NewReinstall.sh
        else
            echo "不支持的系统类型。仅支持 Debian/Ubuntu 或 RedHat/CentOS 系统。"
        fi
        ;;
    7)
        # 宝塔纯净版安装
        if [ -f /etc/redhat-release ]; then
            # CentOS 系统
            yum install -y wget && wget -O install.sh https://install.baota.sbs/install/install_6.0.sh && sh install.sh
        elif [ -f /etc/debian_version ]; then
            # Ubuntu/Debian 系统
            wget -O install.sh https://install.baota.sbs/install/install_6.0.sh && bash install.sh
        else
            echo "不支持的系统类型。仅支持 Debian/Ubuntu 或 CentOS 系统。"
        fi
        ;;
    8)
        # 重启服务器
        reboot
        ;;
    *)
        echo "无效选择，请选择有效的操作编号 (1, 2, 3, 4, 5, 6, 7, 8)"
        ;;
esac
