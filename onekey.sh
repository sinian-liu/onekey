#!/bin/bash

# 设置快捷命令 s
if ! grep -q "alias s=" ~/.bashrc; then
    echo "正在为 s 设置快捷命令..."
    echo "alias s='wget -O /root/onekey.sh https://github.com/sinian-liu/onekey/raw/main/onekey.sh && chmod +x /root/onekey.sh && /root/onekey.sh'" >> ~/.bashrc
    source ~/.bashrc
    echo "快捷命令 s 已设置。"
else
    echo "快捷命令 s 已经存在。"
fi

# 提示用户输入选项
echo "============================================="
echo "服务器推荐：https://my.frantech.ca/aff.php?aff=4337"
echo "VPS评测官方网站：https://www.1373737.xyz/"
echo "YouTube频道：https://www.youtube.com/@cyndiboy7881"
echo "============================================="
echo "请选择要执行的操作："
echo "1. 安装 v2ray 脚本"
echo "2. VPS 一键测试脚本"
echo "3. BBR 安装脚本"
echo "4. 一键永久禁用 IPv6"
echo "5. 一键解除禁用 IPv6"
echo "6. 无人直播云 SRS 安装"
echo "7. 宝塔纯净版安装"
echo "8. 长时间保持 SSH 会话连接不断开"
echo "9. 重启服务器"
echo "============================================="
read -p "请输入选项 [1-9]:" option

case $option in
    1)
        # 安装 v2ray 脚本
        echo "正在安装 v2ray ..."
        wget -P /root -N --no-check-certificate "https://raw.githubusercontent.com/sinian-liu/v2ray-agent-2.5.73/master/install.sh" && chmod 700 /root/install.sh && /root/install.sh
        ;;
    2)
        # VPS 一键测试脚本
        echo "正在进行 VPS 测试 ..."
        bash <(curl -sL https://raw.githubusercontent.com/sinian-liu/VPStest/main/system_info.sh)
        ;;
    3)
        # BBR 安装脚本
        echo "正在安装 BBR ..."
        wget -O tcpx.sh "https://github.com/sinian-liu/Linux-NetSpeed-BBR/raw/master/tcpx.sh" && chmod +x tcpx.sh && ./tcpx.sh
        ;;
    4)
        # 永久禁用 IPv6
        echo "正在禁用 IPv6 ..."
        
        # 检测系统类型（Ubuntu/Debian 或 CentOS/RHEL）
        if [ -f /etc/lsb-release ]; then
            # Ubuntu 或 Debian 系统
            echo "禁用 IPv6："
            sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1
            sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1
            echo "net.ipv6.conf.all.disable_ipv6=1" | sudo tee -a /etc/sysctl.conf
            echo "net.ipv6.conf.default.disable_ipv6=1" | sudo tee -a /etc/sysctl.conf
            sudo sysctl -p
        elif [ -f /etc/redhat-release ]; then
            # CentOS 或 RHEL 系统
            echo "禁用 IPv6："
            sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1
            sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1
            echo "net.ipv6.conf.all.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.conf
            echo "net.ipv6.conf.default.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.conf
            sudo sysctl -p
        else
            echo "无法识别您的操作系统，无法禁用 IPv6。"
        fi
        echo "IPv6 已禁用。"
        ;;
    5)
        # 解除禁用 IPv6
        echo "正在解除禁用 IPv6 ..."
        
        # 检测系统类型（Ubuntu/Debian 或 CentOS/RHEL）
        if [ -f /etc/lsb-release ]; then
            # Ubuntu 或 Debian 系统
            echo "启用 IPv6："
            sudo sysctl -w net.ipv6.conf.all.disable_ipv6=0
            sudo sysctl -w net.ipv6.conf.default.disable_ipv6=0
            sudo sed -i '/net.ipv6.conf.all.disable_ipv6/d' /etc/sysctl.conf
            sudo sed -i '/net.ipv6.conf.default.disable_ipv6/d' /etc/sysctl.conf
            sudo sysctl -p
        elif [ -f /etc/redhat-release ]; then
            # CentOS 或 RHEL 系统
            echo "启用 IPv6："
            sudo sysctl -w net.ipv6.conf.all.disable_ipv6=0
            sudo sysctl -w net.ipv6.conf.default.disable_ipv6=0
            sudo sed -i '/net.ipv6.conf.all.disable_ipv6/d' /etc/sysctl.conf
            sudo sed -i '/net.ipv6.conf.default.disable_ipv6/d' /etc/sysctl.conf
            sudo sysctl -p
        else
            echo "无法识别您的操作系统，无法解除禁用 IPv6。"
        fi
        echo "IPv6 已解除禁用。"
        ;;
    6)
        # 无人直播云 SRS 安装
        echo "正在安装无人直播云 SRS ..."
        
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
            echo "端口 $live_port 已被占用！"
            read -p "请输入一个新的直播端口号 (默认为1935): " new_live_port
            new_live_port=${new_live_port:-1935}
            live_port=$new_live_port
        fi

        # 检查管理端口是否被占用
        check_port $mgmt_port
        if [ $? -eq 1 ]; then
            echo "端口 $mgmt_port 已被占用！"
            read -p "请输入一个新的管理端口号 (默认为2022): " new_mgmt_port
            new_mgmt_port=${new_mgmt_port:-2022}
            mgmt_port=$new_mgmt_port
        fi

        # 安装过程
        sudo apt-get update
        sudo apt-get install docker.io
        docker run --restart always -d --name srs-stack -it -p $live_port:$live_port/tcp -p 1935:1935/tcp -p 1985:1985/tcp \
          -p 8080:8080/tcp -p 8000:8000/udp -p 10080:10080/udp \
          -v $HOME/db:/data ossrs/srs-stack:5
        echo "默认登录地址：http://你的服务器ip:$mgmt_port/mgmt"
        ;;
    7)
        # 宝塔纯净版安装
        echo "正在安装宝塔 ..."
        # 安装脚本
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
        echo "无效选项，请重新输入！"
        ;;
esac
