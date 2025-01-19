#!/bin/bash

clear
echo -e "\033[1;31m提示：您下次可以直接输入 's' 来快速启动此脚本。\033[0m"
echo -e "\033[1;33m=============================================\033[0m"
echo -e "\033[1;32m服务器推荐：\033[0m https://my.frantech.ca/aff.php?aff=4337"
echo -e "\033[1;32mVPS评测官方网站：\033[0m https://www.1373737.xyz/"
echo -e "\033[1;32mYouTube频道：\033[0m https://www.youtube.com/@cyndiboy7881"
echo -e "\033[1;33m=============================================\033[0m"
echo -e "\033[1;33m请输入选项并按回车键：\033[0m"
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
        echo "开始安装 v2ray 脚本..."
        wget -O /root/install-v2ray.sh https://raw.githubusercontent.com/v2ray/v2ray-core/master/release/install.sh && bash /root/install-v2ray.sh
        if [ $? -eq 0 ]; then
            echo "v2ray 脚本安装成功！"
        else
            echo "v2ray 脚本安装失败！"
        fi
        ;;
    2)
        # VPS 一键测试脚本
        echo "开始下载并执行 VPS 测试脚本..."
        wget -O /root/vps-test.sh https://github.com/sinian-liu/VPStest/raw/main/system_info.sh && chmod +x /root/vps-test.sh && bash /root/vps-test.sh
        if [ $? -eq 0 ]; then
            echo "VPS 测试脚本执行完成！"
        else
            echo "VPS 测试脚本执行失败！"
        fi
        ;;
    3)
        # BBR 安装脚本
        echo "开始安装 BBR 脚本..."
        wget -O /root/bbr.sh https://github.com/sinian-liu/Linux-NetSpeed-BBR/raw/master/tcpx.sh && chmod +x /root/bbr.sh && bash /root/bbr.sh
        if [ $? -eq 0 ]; then
            echo "BBR 安装成功！"
        else
            echo "BBR 安装失败！"
        fi
        ;;
    4)
        # 永久禁用 IPv6
        echo "开始禁用 IPv6..."
        if [ -f /etc/debian_version ]; then
            sudo bash -c 'echo -e "net.ipv6.conf.all.disable_ipv6 = 1\nnet.ipv6.conf.default.disable_ipv6 = 1\nnet.ipv6.conf.lo.disable_ipv6 = 1" >> /etc/sysctl.conf && sysctl -p'
            if [ $? -eq 0 ]; then
                echo "IPv6 禁用成功！"
            else
                echo "IPv6 禁用失败！"
            fi
        elif [ -f /etc/redhat-release ]; then
            sudo bash -c 'echo -e "net.ipv6.conf.all.disable_ipv6 = 1\nnet.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf && sysctl -p'
            if [ $? -eq 0 ]; then
                echo "IPv6 禁用成功！"
            else
                echo "IPv6 禁用失败！"
            fi
        else
            echo "不支持的系统类型。仅支持 Debian/Ubuntu 或 RedHat/CentOS 系统。"
        fi
        ;;
    5)
        # 解除禁用 IPv6
        echo "开始解除禁用 IPv6..."
        if [ -f /etc/debian_version ]; then
            sudo sed -i '/disable_ipv6/s/1/0/' /etc/sysctl.conf && sudo sysctl -p && sudo systemctl restart networking
            if [ $? -eq 0 ]; then
                echo "IPv6 解禁成功！"
            else
                echo "IPv6 解禁失败！"
            fi
        elif [ -f /etc/redhat-release ]; then
            sudo sed -i '/disable_ipv6/s/1/0/' /etc/sysctl.conf && sudo sysctl -p && sudo systemctl restart network
            if [ $? -eq 0 ]; then
                echo "IPv6 解禁成功！"
            else
                echo "IPv6 解禁失败！"
            fi
        else
            echo "不支持的系统类型。仅支持 Debian/Ubuntu 或 RedHat/CentOS 系统。"
        fi
        ;;
    6)
        # KVM 安装 Windows 2003 一键命令
        echo "开始检测系统类型..."
        if [ -f /etc/debian_version ]; then
            echo "检测到系统为 Debian/Ubuntu"
            echo "正在安装必要的依赖..."
            apt-get install -y xz-utils openssl gawk file wget screen
            if [ $? -eq 0 ]; then
                echo "依赖安装成功！"
            else
                echo "依赖安装失败！"
            fi
            echo "正在启动屏幕会话..."
            screen -S os
            if [ $? -eq 0 ]; then
                echo "屏幕会话启动成功！"
            else
                echo "屏幕会话启动失败！"
            fi
            echo "正在更新系统..."
            apt update -y && apt dist-upgrade -y
            if [ $? -eq 0 ]; then
                echo "系统更新成功！"
            else
                echo "系统更新失败！"
            fi
            echo "开始下载并安装 Windows 2003 脚本..."
            wget --no-check-certificate -O NewReinstall.sh https://git.io/newbetags && chmod a+x NewReinstall.sh && bash NewReinstall.sh
            if [ $? -eq 0 ]; then
                echo "Windows 2003 安装脚本执行完成！"
            else
                echo "Windows 2003 安装脚本执行失败！"
            fi
        elif [ -f /etc/redhat-release ]; then
            echo "检测到系统为 RedHat/CentOS"
            echo "正在安装必要的依赖..."
            yum install -y xz openssl gawk file glibc-common wget screen
            if [ $? -eq 0 ]; then
                echo "依赖安装成功！"
            else
                echo "依赖安装失败！"
            fi
            echo "正在启动屏幕会话..."
            screen -S os
            if [ $? -eq 0 ]; then
                echo "屏幕会话启动成功！"
            else
                echo "屏幕会话启动失败！"
            fi
            echo "正在更新系统..."
            yum update -y
            if [ $? -eq 0 ]; then
                echo "系统更新成功！"
            else
                echo "系统更新失败！"
            fi
            echo "开始下载并安装 Windows 2003 脚本..."
            wget --no-check-certificate -O NewReinstall.sh https://git.io/newbetags && chmod a+x NewReinstall.sh && bash NewReinstall.sh
            if [ $? -eq 0 ]; then
                echo "Windows 2003 安装脚本执行完成！"
            else
                echo "Windows 2003 安装脚本执行失败！"
            fi
        else
            echo "不支持的系统类型。仅支持 Debian/Ubuntu 或 RedHat/CentOS 系统。"
        fi
        ;;
    7)
        # 宝塔纯净版安装
        if [ -f /etc/redhat-release ]; then
            yum install -y wget && wget -O install.sh https://install.baota.sbs/install/install_6.0.sh && sh install.sh
        elif [ -f /etc/debian_version ]; then
            wget -O install.sh https://install.baota.sbs/install/install_6.0.sh && bash install.sh
        else
            echo "不支持的系统类型。仅支持 Debian/Ubuntu 或 RedHat/CentOS 系统。"
        fi
        ;;
    8)
        # 重启服务器
        echo "正在重启服务器..."
        reboot
        ;;
    *)
        echo "无效的选项！"
        ;;
esac
