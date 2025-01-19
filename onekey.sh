#!/bin/bash

clear
echo -e "\033[31m提示：您下次可以直接输入 's' 来快速启动此脚本。\033[0m"
echo "============================================="
echo -e "\033[32m服务器推荐：https://my.frantech.ca/aff.php?aff=4337\033[0m"
echo -e "\033[32mVPS评测官方网站：https://www.1373737.xyz/\033[0m"
echo -e "\033[32mYouTube频道：https://www.youtube.com/@cyndiboy7881\033[0m"
echo "============================================="
echo -e "\033[33m请选择要执行的操作：\033[0m"
echo -e "\033[33m1. 安装 v2ray 脚本\033[0m"
echo -e "\033[33m2. VPS 一键测试脚本\033[0m"
echo -e "\033[33m3. BBR 安装脚本\033[0m"
echo -e "\033[33m4. 一键永久禁用 IPv6\033[0m"
echo -e "\033[33m5. 一键解除禁用 IPv6\033[0m"
echo -e "\033[33m6. 无人直播云 SRS 安装\033[0m"
echo -e "\033[33m7. 宝塔纯净版安装\033[0m"
echo -e "\033[33m8. 重启服务器\033[0m"
echo -n "输入选项: "
read opt

case $opt in
    1)
        # 安装 v2ray 脚本
        wget -N https://raw.githubusercontent.com/sinian-liu/onekey-v2ray/master/install.sh && bash install.sh
        ;;
    2)
        # VPS 一键测试脚本
        bash <(curl -sL https://raw.githubusercontent.com/sinian-liu/VPStest/main/system_info.sh)
        ;;
    3)
        # BBR 安装脚本
        wget -O tcpx.sh "https://github.com/sinian-liu/Linux-NetSpeed-BBR/raw/master/tcpx.sh" && chmod +x tcpx.sh && ./tcpx.sh
        ;;
    4)
        # 一键永久禁用 IPv6
        if [[ -f /etc/debian_version ]]; then
            sudo bash -c 'echo -e "net.ipv6.conf.all.disable_ipv6 = 1\nnet.ipv6.conf.default.disable_ipv6 = 1\nnet.ipv6.conf.lo.disable_ipv6 = 1" >> /etc/sysctl.conf && sysctl -p'
        elif [[ -f /etc/redhat-release ]]; then
            sudo bash -c 'echo -e "net.ipv6.conf.all.disable_ipv6 = 1\nnet.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf && sysctl -p'
        else
            echo "不支持的操作系统"
        fi
        ;;
    5)
        # 一键解除禁用 IPv6
        if [[ -f /etc/debian_version ]]; then
            sudo sed -i '/disable_ipv6/s/1/0/' /etc/sysctl.conf && sudo sysctl -p && sudo systemctl restart networking
        elif [[ -f /etc/redhat-release ]]; then
            sudo sed -i '/disable_ipv6/s/1/0/' /etc/sysctl.conf && sudo sysctl -p && sudo systemctl restart network
        else
            echo "不支持的操作系统"
        fi
        ;;
    6)
        # 无人直播云 SRS 安装
        echo "开始安装无人直播云 SRS..."

        # 提示用户输入直播端口号
        read -p "请输入要使用的直播端口号 (默认为1935): " live_port
        live_port=${live_port:-1935}  # 如果没有输入，则使用默认端口1935

        # 提示用户输入流媒体端口号
        read -p "请输入要使用的流媒体端口号 (默认为8080): " stream_port
        stream_port=${stream_port:-8080}  # 如果没有输入，则使用默认端口8080

        # 更新软件源和安装 Docker
        sudo apt-get update
        sudo apt-get install -y docker.io

        # 开放用户输入的端口
        echo "正在开放端口 $live_port 和 $stream_port..."
        sudo ufw allow $live_port/tcp
        sudo ufw allow $stream_port/tcp
        sudo ufw reload

        # 运行 SRS 容器
        docker run --restart always -d --name srs-stack -it -p $live_port:$live_port/tcp -p 1985:1985/tcp \
          -p $stream_port:$stream_port/tcp -p 8000:8000/udp -p 10080:10080/udp \
          -v $HOME/db:/data ossrs/srs-stack:5

        if [ $? -eq 0 ]; then
            echo "SRS 安装成功！"
            SERVER_IP=$(curl -s ifconfig.me)
            echo "默认登录地址：http://$SERVER_IP:2022/mgmt"
        else
            echo "SRS 安装失败！"
        fi
        ;;
    7)
        # 宝塔纯净版安装
        echo "正在安装宝塔面板..."
        if [[ -f /etc/debian_version || -f /etc/ubuntu-release ]]; then
            wget -O install.sh https://install.baota.sbs/install/install_6.0.sh && bash install.sh
        elif [[ -f /etc/redhat-release ]]; then
            yum install -y wget && wget -O install.sh https://install.baota.sbs/install/install_6.0.sh && sh install.sh
        else
            echo "不支持的操作系统"
        fi
        ;;
    8)
        # 重启服务器
        echo "正在重启服务器..."
        sudo reboot
        ;;
    *)
        echo "无效选择，请选择有效的操作编号 (1-8)"
        ;;
esac
