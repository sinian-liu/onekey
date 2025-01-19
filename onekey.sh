#!/bin/bash

echo -e "\033[1;32m请输入您要执行的操作（请输入对应的数字）：\033[0m"
echo -e "\033[1;33m1. 安装 v2ray 脚本"
echo -e "2. VPS 一键测试脚本"
echo -e "3. BBR 安装脚本"
echo -e "4. 一键永久禁用 IPv6"
echo -e "5. 一键解除禁用 IPv6"
echo -e "6. 无人直播云SRS安装"
echo -e "7. 宝塔纯净版安装"
echo -e "8. 长时间保持 SSH 会话连接不断开"
echo -e "9. 重启服务器"

read -p "请输入选项: " option

case $option in
1)
    # 安装 v2ray 脚本
    wget -O install.sh https://raw.githubusercontent.com/sinian-liu/v2ray-agent-2.7.3/master/install.sh && bash install.sh
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
    # 永久禁用 IPv6
    if [[ -f /etc/lsb-release || -f /etc/debian_version ]]; then
        # Ubuntu/Debian 系统
        sudo bash -c 'echo -e "net.ipv6.conf.all.disable_ipv6 = 1\nnet.ipv6.conf.default.disable_ipv6 = 1\nnet.ipv6.conf.lo.disable_ipv6 = 1" >> /etc/sysctl.conf && sysctl -p'
    elif [[ -f /etc/redhat-release || -f /etc/centos-release ]]; then
        # CentOS 系统
        sudo bash -c 'echo -e "net.ipv6.conf.all.disable_ipv6 = 1\nnet.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf && sysctl -p'
    fi
    ;;
5)
    # 解除禁用 IPv6
    if [[ -f /etc/lsb-release || -f /etc/debian_version ]]; then
        # Ubuntu/Debian 系统
        sudo sed -i '/disable_ipv6/s/1/0/' /etc/sysctl.conf && sudo sysctl -p && sudo systemctl restart networking
    elif [[ -f /etc/redhat-release || -f /etc/centos-release ]]; then
        # CentOS 系统
        sudo sed -i '/disable_ipv6/s/1/0/' /etc/sysctl.conf && sudo sysctl -p && sudo systemctl restart network
    fi
    ;;
6)
    # 无人直播云SRS安装
    read -p "请输入要使用的直播端口号 (默认为1935): " live_port
    live_port=${live_port:-1935}  # 如果没有输入，则使用默认端口1935

    read -p "请输入要使用的管理端口号 (默认为2022): " mgmt_port
    mgmt_port=${mgmt_port:-2022}  # 如果没有输入，则使用默认端口2022

    echo "正在安装无人直播云 SRS，并开放端口 $live_port 和 $mgmt_port..."
    sudo apt-get update
    sudo apt-get install docker.io
    sudo docker run --restart always -d --name srs-stack -it -p $live_port:$live_port -p 1935:1935/tcp -p 1985:1985/tcp \
      -p 8080:8080/tcp -p 8000:8000/udp -p 10080:10080/udp \
      -v $HOME/db:/data ossrs/srs-stack:5
    echo "默认登录地址：http://$(hostname -I | awk '{print $1}'):$mgmt_port/mgmt"
    ;;
7)
    # 宝塔纯净版安装
    if [[ -f /etc/lsb-release || -f /etc/debian_version ]]; then
        # Ubuntu/Debian 系统
        wget -O install.sh https://install.baota.sbs/install/install_6.0.sh && bash install.sh
    elif [[ -f /etc/redhat-release || -f /etc/centos-release ]]; then
        # CentOS 系统
        yum install -y wget && wget -O install.sh https://install.baota.sbs/install/install_6.0.sh && sh install.sh
    fi
    ;;
8)
    # 长时间保持 SSH 会话连接不断开
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

    echo "配置完成！心跳请求间隔为 $interval 分钟，最大无响应次数为 $max_count。"
    ;;
9)
    # 重启服务器
    echo "正在重启服务器..."
    sudo reboot
    ;;
*)
    echo "无效选择，请选择有效的操作编号 (1, 2, 3, 4, 5, 6, 7, 8, 9)"
    ;;
esac
