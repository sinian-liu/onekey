#!/bin/bash

# 设置颜色
GREEN="\033[32m"
RED="\033[31m"
YELLOW="\033[33m"
RESET="\033[0m"

# 系统检测函数
check_system() {
    if [ -f /etc/lsb-release ]; then
        SYSTEM="ubuntu"
    elif [ -f /etc/redhat-release ]; then
        SYSTEM="centos"
    elif [ -f /etc/fedora-release ]; then
        SYSTEM="fedora"
    else
        SYSTEM="unknown"
    fi
}

# 安装 wget 函数
install_wget() {
    check_system
    if [ "$SYSTEM" == "ubuntu" ] || [ "$SYSTEM" == "debian" ]; then
        echo -e "${YELLOW}检测到 wget 缺失，正在安装...${RESET}"
        sudo apt update && sudo apt install -y wget
    elif [ "$SYSTEM" == "centos" ]; then
        echo -e "${YELLOW}检测到 wget 缺失，正在安装...${RESET}"
        sudo yum install -y wget
    elif [ "$SYSTEM" == "fedora" ]; then
        echo -e "${YELLOW}检测到 wget 缺失，正在安装...${RESET}"
        sudo dnf install -y wget
    else
        echo -e "${RED}无法识别系统，无法安装 wget。${RESET}"
    fi
}

# 检查并安装 wget
if ! command -v wget &> /dev/null; then
    install_wget
    if ! command -v wget &> /dev/null; then
        echo -e "${RED}安装 wget 失败，请手动检查问题！${RESET}"
        exit 1
    fi
fi

# 系统更新函数
update_system() {
    check_system
    if [ "$SYSTEM" == "ubuntu" ] || [ "$SYSTEM" == "debian" ]; then
        echo -e "${GREEN}正在更新 Debian/Ubuntu 系统...${RESET}"
        sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && sudo apt clean
    elif [ "$SYSTEM" == "centos" ]; then
        echo -e "${GREEN}正在更新 CentOS 系统...${RESET}"
        sudo yum update -y && sudo yum clean all
    elif [ "$SYSTEM" == "fedora" ]; then
        echo -e "${GREEN}正在更新 Fedora 系统...${RESET}"
        sudo dnf update -y && sudo dnf clean all
    else
        echo -e "${RED}无法识别您的操作系统，跳过更新步骤。${RESET}"
    fi
}

# 增加快捷命令 s 设置（如果没有的话）
if ! grep -q "alias s=" ~/.bashrc; then
    echo "正在为 s 设置快捷命令..."
    echo "alias s='bash <(curl -sL https://raw.githubusercontent.com/sinian-liu/onekey/main/onekey.sh)'" >> ~/.bashrc
    source ~/.bashrc
    echo "快捷命令 s 已设置。"
else
    echo "快捷命令 s 已经存在。"
fi

# 提示用户输入选项
echo -e "${GREEN}=============================================${RESET}"
echo -e "${GREEN}服务器推荐：https://my.frantech.ca/aff.php?aff=4337${RESET}"
echo -e "${GREEN}VPS评测官方网站：https://www.1373737.xyz/${RESET}"
echo -e "${GREEN}YouTube频道：https://www.youtube.com/@cyndiboy7881${RESET}"
echo -e "${GREEN}=============================================${RESET}"
echo "请选择要执行的操作："
echo -e "${YELLOW}1. VPS一键测试${RESET}"
echo -e "${YELLOW}2. 安装BBR${RESET}"
echo -e "${YELLOW}3. 安装v2ray${RESET}"
echo -e "${YELLOW}4. 安装无人直播云SRS${RESET}"
echo -e "${YELLOW}5. 安装宝塔纯净版${RESET}"
echo -e "${YELLOW}6. 系统更新${RESET}"
echo -e "${YELLOW}7. 重启服务器${RESET}"
echo -e "${YELLOW}8. 修改服务器密码${RESET}"
echo -e "${YELLOW}9. 一键永久禁用IPv6${RESET}"
echo -e "${YELLOW}10. 一键解除禁用IPv6${RESET}"
echo -e "${YELLOW}11.服务器时区修改为中国时区${RESET}"
echo -e "${YELLOW}12.保持SSH会话一直连接不断开${RESET}"
echo -e "${YELLOW}13.安装Windows或Linux系统${RESET}"
echo -e "${YELLOW}14.服务器对服务器文件传输${RESET}"
echo -e "${YELLOW}15.安装探针并绑定域名${RESET}"
echo -e "${YELLOW}16.共用端口（反代）${RESET}"
echo -e "${YELLOW}17.脚本更新${RESET}"
echo -e "${GREEN}=============================================${RESET}"

read -p "请输入选项:" option

case $option in
    1)
        # VPS 一键测试脚本
        echo -e "${GREEN}正在进行 VPS 测试 ...${RESET}"
        bash <(curl -sL https://raw.githubusercontent.com/sinian-liu/VPStest/main/system_info.sh)
        ;;
    2)
        # BBR 安装脚本
        echo -e "${GREEN}正在安装 BBR ...${RESET}"
        wget -O tcpx.sh "https://github.com/sinian-liu/Linux-NetSpeed-BBR/raw/master/tcpx.sh" && chmod +x tcpx.sh && ./tcpx.sh
        ;;
    3)
        # 安装 v2ray 脚本
        echo -e "${GREEN}正在安装 v2ray ...${RESET}"
        wget -P /root -N --no-check-certificate "https://raw.githubusercontent.com/sinian-liu/v2ray-agent-2.5.73/master/install.sh" && chmod 700 /root/install.sh && /root/install.sh
        ;;
    4)
        # 无人直播云 SRS 安装
        echo -e "${GREEN}正在安装无人直播云 SRS ...${RESET}"
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

        # 检查管理端口是否被占用
        check_port $mgmt_port
        if [ $? -eq 1 ]; then
            echo -e "${RED}端口 $mgmt_port 已被占用！${RESET}"
            read -p "请输入其他端口号作为管理端口: " mgmt_port
        fi

        # 安装 Docker
        sudo apt-get update
        sudo apt-get install -y docker.io

        # 启动 SRS 容器
        docker run --restart always -d --name srs-stack -it -p $mgmt_port:2022 -p 1935:1935/tcp -p 1985:1985/tcp \
          -p 8080:8080/tcp -p 8000:8000/udp -p 10080:10080/udp \
          -v $HOME/db:/data ossrs/srs-stack:5

        # 获取服务器 IPv4 地址
        server_ip=$(curl -s4 ifconfig.me)

        # 输出访问地址
        echo -e "${GREEN}SRS 安装完成！您可以通过以下地址访问管理界面:${RESET}"
        echo -e "${YELLOW}http://$server_ip:$mgmt_port/mgmt${RESET}"
        ;;

    5)
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

    6)
        # 系统更新命令
        sudo apt-get update -y && sudo apt-get upgrade -y
        ;;

    7)
        # 重启服务器
        echo -e "${GREEN}正在重启服务器 ...${RESET}"
        sudo reboot
        ;;

    8)
        # 修改服务器密码
        echo -e "${GREEN}请输入新密码：${RESET}"
        read -s new_password
        echo -e "${GREEN}请再次输入新密码以确认：${RESET}"
        read -s confirm_password

        if [ "$new_password" = "$confirm_password" ]; then
            # 修改 root 用户密码
            echo -e "$new_password\n$new_password" | sudo passwd root &>/dev/null
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}密码修改成功！${RESET}"
            else
                echo -e "${RED}密码修改失败，请检查系统配置或权限。${RESET}"
            fi
        else
            echo -e "${RED}两次输入的密码不一致，请重试。${RESET}"
        fi
        ;;
        
    9)
        # 永久禁用 IPv6
        echo -e "${GREEN}正在禁用 IPv6 ...${RESET}"
        # 检测系统类型（Ubuntu/Debian 或 CentOS/RHEL）
        if [ -f /etc/lsb-release ]; then
            # Ubuntu 或 Debian 系统
            sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1
            sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1
            echo "net.ipv6.conf.all.disable_ipv6=1" | sudo tee -a /etc/sysctl.conf
            echo "net.ipv6.conf.default.disable_ipv6=1" | sudo tee -a /etc/sysctl.conf
            sudo sysctl -p
        elif [ -f /etc/redhat-release ]; then
            # CentOS 或 RHEL 系统
            sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1
            sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1
            echo "net.ipv6.conf.all.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.conf
            echo "net.ipv6.conf.default.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.conf
            sudo sysctl -p
        else
            echo -e "${RED}无法识别您的操作系统，无法禁用 IPv6。${RESET}"
        fi
        ;;

    10)
        # 解除禁用 IPv6
        echo -e "${GREEN}正在解除禁用 IPv6 ...${RESET}"
        # 检测系统类型（Ubuntu/Debian 或 CentOS/RHEL）
        if [ -f /etc/lsb-release ]; then
            # Ubuntu 或 Debian 系统
            sudo sysctl -w net.ipv6.conf.all.disable_ipv6=0
            sudo sysctl -w net.ipv6.conf.default.disable_ipv6=0
            sudo sed -i '/net.ipv6.conf.all.disable_ipv6/d' /etc/sysctl.conf
            sudo sed -i '/net.ipv6.conf.default.disable_ipv6/d' /etc/sysctl.conf
            sudo sysctl -p
        elif [ -f /etc/redhat-release ]; then
            # CentOS 或 RHEL 系统
            sudo sysctl -w net.ipv6.conf.all.disable_ipv6=0
            sudo sysctl -w net.ipv6.conf.default.disable_ipv6=0
            sudo sed -i '/net.ipv6.conf.all.disable_ipv6/d' /etc/sysctl.conf
            sudo sed -i '/net.ipv6.conf.default.disable_ipv6/d' /etc/sysctl.conf
            sudo sysctl -p
        else
            echo -e "${RED}无法识别您的操作系统，无法解除禁用 IPv6。${RESET}"
        fi
        ;;

    11)
        # 服务器时区修改为中国时区
        echo -e "${GREEN}正在修改服务器时区为中国时区 ...${RESET}"
        sudo ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
        sudo service cron restart
        ;;

    12)
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

    13)
        # KVM安装系统,检测操作系统类型
        check_system() {
            if grep -qi "debian" /etc/os-release || grep -qi "ubuntu" /etc/os-release; then
                SYSTEM="debian"
            elif grep -qi "centos" /etc/os-release || grep -qi "red hat" /etc/os-release; then
                SYSTEM="centos"
            else
                SYSTEM="unknown"
            fi
        }

        if [[ $option -eq 12 ]]; then
            echo -e "${GREEN}开始安装 KVM 系统...${RESET}"
            check_system

            if [[ $SYSTEM == "debian" ]]; then
                echo -e "${YELLOW}检测到系统为 Debian/Ubuntu，开始安装必要依赖...${RESET}"
                apt-get install -y xz-utils openssl gawk file wget screen
                if [[ $? -eq 0 ]]; then
                    echo -e "${YELLOW}必要依赖安装完成，开始更新系统软件包...${RESET}"
                    apt update -y && apt dist-upgrade -y
                    if [[ $? -ne 0 ]]; then
                        echo -e "${RED}系统更新失败，请检查网络或镜像源！${RESET}"
                        exit 1
                    fi
                else
                    echo -e "${RED}必要依赖安装失败，请检查网络或镜像源！${RESET}"
                    exit 1
                fi

            elif [[ $SYSTEM == "centos" ]]; then
                echo -e "${YELLOW}检测到系统为 RedHat/CentOS，开始安装必要依赖...${RESET}"
                yum install -y xz openssl gawk file glibc-common wget screen
                if [[ $? -ne 0 ]]; then
                    echo -e "${RED}依赖安装失败，请检查网络或镜像源！${RESET}"
                    exit 1
                fi
            else
                echo -e "${RED}不支持的操作系统！${RESET}"
                exit 1
            fi

            echo -e "${YELLOW}开始下载并运行安装脚本...${RESET}"
            wget --no-check-certificate -O NewReinstall.sh https://git.io/newbetags
            if [[ $? -eq 0 ]]; then
                chmod a+x NewReinstall.sh
                bash NewReinstall.sh
                echo -e "${GREEN}安装完成！${RESET}"
            else
                echo -e "${RED}脚本下载失败，请检查网络或镜像源！${RESET}"
                exit 1
            fi
        fi
        ;;

14)
    # 服务器对服务器传文件
    echo -e "${GREEN}服务器对服务器传文件${RESET}"

    # 检查是否安装了 sshpass
    if ! command -v sshpass &> /dev/null; then
        echo -e "${YELLOW}检测到 sshpass 缺失，正在安装...${RESET}"
        sudo apt update && sudo apt install -y sshpass
        if ! command -v sshpass &> /dev/null; then
            echo -e "${RED}安装 sshpass 失败，请手动安装！${RESET}"
            exit 1
        fi
    fi

    # 输入目标服务器 IP 地址
    read -p "请输入目标服务器IP地址（例如：185.106.96.93）： " target_ip

    # 输入目标服务器 SSH 端口（默认为 22）
    read -p "请输入目标服务器SSH端口（默认为22）： " ssh_port
    ssh_port=${ssh_port:-22}  # 如果未输入，则使用默认端口 22

    # 输入目标服务器密码
    read -s -p "请输入目标服务器密码：" ssh_password
    echo  # 换行

    # 验证目标服务器的 SSH 连接
    echo -e "${YELLOW}正在验证目标服务器的 SSH 连接...${RESET}"
    sshpass -p "$ssh_password" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p "$ssh_port" root@"$target_ip" "echo 'SSH 连接成功！'" &> /dev/null
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}SSH 连接验证成功！${RESET}"

        # 输入源文件路径和目标文件路径
        read -p "请输入源文件路径（例如：/root/data/vlive/test.mp4）： " source_file
        read -p "请输入目标文件路径（例如：/root/data/vlive/）： " target_path

        # 执行 scp 命令
        echo -e "${YELLOW}正在传输文件，请稍候...${RESET}"
        sshpass -p "$ssh_password" scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -P "$ssh_port" "$source_file" root@"$target_ip":"$target_path"
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}文件传输成功！${RESET}"
        else
            echo -e "${RED}文件传输失败，请检查路径和网络连接。${RESET}"
        fi
    else
        echo -e "${RED}SSH 连接失败，请检查以下内容：${RESET}"
        echo -e "${YELLOW}1. 目标服务器 IP 地址是否正确。${RESET}"
        echo -e "${YELLOW}2. 目标服务器的 SSH 服务是否已开启。${RESET}"
        echo -e "${YELLOW}3. 目标服务器的 root 用户密码是否正确。${RESET}"
        echo -e "${YELLOW}4. 目标服务器的防火墙是否允许 SSH 连接。${RESET}"
        echo -e "${YELLOW}5. 目标服务器的 SSH 端口是否为 $ssh_port。${RESET}"
    fi
    ;;
15)
    # 安装 NekoNekoStatus 服务器探针并绑定域名
    echo -e "${GREEN}正在安装 NekoNekoStatus 服务器探针并绑定域名...${RESET}"

    # 检查 Docker 是否已安装
    if ! command -v docker &> /dev/null; then
        echo -e "${YELLOW}检测到 Docker 未安装，正在安装 Docker...${RESET}"
        curl -fsSL https://get.docker.com | bash -s docker
        if ! command -v docker &> /dev/null; then
            echo -e "${RED}Docker 安装失败，请手动安装 Docker！${RESET}"
            exit 1
        fi
    fi

    # 询问容器端口
    read -p "请输入 NekoNekoStatus 容器端口（默认为 5555）： " container_port
    container_port=${container_port:-5555}  # 如果未输入，则使用默认端口 5555

    # 询问反向代理端口
    read -p "请输入反向代理端口（默认为 80）： " proxy_port
    proxy_port=${proxy_port:-80}  # 如果未输入，则使用默认端口 80

    # 检测端口是否开放
    check_port() {
        local port=$1
        if netstat -tuln | grep ":$port" > /dev/null; then
            return 1  # 端口已被占用
        else
            return 0  # 端口未占用
        fi
    }

    # 检测容器端口
    check_port $container_port
    if [ $? -eq 1 ]; then
        echo -e "${RED}端口 $container_port 已被占用，请选择其他端口！${RESET}"
        exit 1
    fi

    # 检测反向代理端口
    check_port $proxy_port
    if [ $? -eq 1 ]; then
        echo -e "${RED}端口 $proxy_port 已被占用，请选择其他端口！${RESET}"
        exit 1
    fi

    # 开放端口
    open_port() {
        local port=$1
        if command -v ufw &> /dev/null; then
            sudo ufw allow $port
        elif command -v firewall-cmd &> /dev/null; then
            sudo firewall-cmd --zone=public --add-port=$port/tcp --permanent
            sudo firewall-cmd --reload
        else
            echo -e "${YELLOW}未检测到 ufw 或 firewalld，请手动开放端口 $port。${RESET}"
        fi
    }

    # 开放容器端口
    echo -e "${YELLOW}正在开放容器端口 $container_port...${RESET}"
    open_port $container_port

    # 开放反向代理端口
    echo -e "${YELLOW}正在开放反向代理端口 $proxy_port...${RESET}"
    open_port $proxy_port

    # 拉取并运行 NekoNekoStatus Docker 容器
    echo -e "${YELLOW}正在拉取 NekoNekoStatus Docker 镜像...${RESET}"
    docker pull nkeonkeo/nekonekostatus:latest

    echo -e "${YELLOW}正在启动 NekoNekoStatus 容器...${RESET}"
    docker run --restart=on-failure --name nekonekostatus -p $container_port:5555 -d nkeonkeo/nekonekostatus:latest

    # 提示用户输入域名和邮箱
    read -p "请输入您的域名（例如：www.example.com）： " domain
    read -p "请输入您的邮箱（用于 Let's Encrypt 证书）： " email

    # 安装 Nginx 和 Certbot
    if ! command -v nginx &> /dev/null; then
        echo -e "${YELLOW}正在安装 Nginx...${RESET}"
        sudo apt update -y
        sudo apt install -y nginx
    fi

    if ! command -v certbot &> /dev/null; then
        echo -e "${YELLOW}正在安装 Certbot...${RESET}"
        sudo apt install -y certbot python3-certbot-nginx
    fi

    # 配置 Nginx
    echo -e "${YELLOW}正在配置 Nginx...${RESET}"
    cat > /etc/nginx/sites-available/$domain <<EOL
server {
    listen $proxy_port;
    server_name $domain;

    location / {
        proxy_pass http://127.0.0.1:$container_port;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOL

    # 启用站点配置
    sudo ln -s /etc/nginx/sites-available/$domain /etc/nginx/sites-enabled/
    sudo nginx -t && sudo systemctl reload nginx

    # 申请 Let's Encrypt 证书
    echo -e "${YELLOW}正在申请 Let's Encrypt 证书...${RESET}"
    sudo certbot --nginx -d $domain --email $email --agree-tos --non-interactive

    # 配置自动续期
    echo -e "${YELLOW}正在配置证书自动续期...${RESET}"
    (crontab -l 2>/dev/null; echo "0 0 * * * certbot renew --quiet && systemctl reload nginx") | crontab -

    echo -e "${GREEN}NekoNekoStatus 安装和域名绑定完成！${RESET}"
    echo -e "${YELLOW}您现在可以通过 https://$domain 访问探针服务了。${RESET}"
    echo -e "${YELLOW}容器端口: $container_port${RESET}"
    echo -e "${YELLOW}反向代理端口: $proxy_port${RESET}"
    echo -e "${YELLOW}默认密码: nekonekostatus${RESET}"
    echo -e "${YELLOW}安装后务必修改密码！${RESET}"
    ;;
16)
    # 共用端口（反代）
    echo -e "${GREEN}正在配置HTTPS运行多个Web服务...${RESET}"

    # 安装 Nginx 和 Certbot
    if ! command -v nginx &> /dev/null; then
        echo -e "${YELLOW}正在安装 Nginx...${RESET}"
        sudo apt update -y
        sudo apt install -y nginx
    fi

    if ! command -v certbot &> /dev/null; then
        echo -e "${YELLOW}正在安装 Certbot...${RESET}"
        sudo apt install -y certbot python3-certbot-nginx
    fi

    # 检测端口是否被占用
    check_port() {
        local port=$1
        if netstat -tuln | grep ":$port" > /dev/null; then
            return 1  # 端口已被占用
        else
            return 0  # 端口未占用
        fi
    }

    # 获取占用端口的服务
    get_service_using_port() {
        local port=$1
        sudo netstat -tuln | grep ":$port" | awk '{print $7}' | cut -d'/' -f1
    }

    # 自动分配可用端口
    find_available_port() {
        local start_port=$1
        local end_port=$2
        for port in $(seq $start_port $end_port); do
            if ! check_port $port; then
                echo $port
                return 0
            fi
        done
        echo -e "${RED}未找到可用端口！${RESET}"
        exit 1
    }

    # 记录被停止的服务
    stopped_services=""

    # 检测 80 和 443 端口是否被占用
    check_port 80
    if [ $? -eq 1 ]; then
        echo -e "${RED}端口 80 已被以下服务占用：${RESET}"
        service_80=$(get_service_using_port 80)
        echo -e "${YELLOW}$service_80${RESET}"
        read -p "是否停止该服务并释放端口 80？(y/n): " stop_service
        if [[ $stop_service == "y" || $stop_service == "Y" ]]; then
            sudo systemctl stop $service_80
            sudo systemctl disable $service_80
            stopped_services="$stopped_services $service_80"
            echo -e "${GREEN}已停止服务 $service_80 并释放端口 80。${RESET}"
        else
            new_port_80=$(find_available_port 8080 9000)
            echo -e "${YELLOW}已将服务 $service_80 的端口修改为 $new_port_80。${RESET}"
            # 更新服务的端口配置（假设服务是 Nginx）
            sudo sed -i "s/listen 80/listen $new_port_80/g" /etc/nginx/sites-available/*
            sudo systemctl restart nginx
        fi
    fi

    check_port 443
    if [ $? -eq 1 ]; then
        echo -e "${RED}端口 443 已被以下服务占用：${RESET}"
        service_443=$(get_service_using_port 443)
        echo -e "${YELLOW}$service_443${RESET}"
        read -p "是否停止该服务并释放端口 443？(y/n): " stop_service
        if [[ $stop_service == "y" || $stop_service == "Y" ]]; then
            sudo systemctl stop $service_443
            sudo systemctl disable $service_443
            stopped_services="$stopped_services $service_443"
            echo -e "${GREEN}已停止服务 $service_443 并释放端口 443。${RESET}"
        else
            new_port_443=$(find_available_port 8443 9000)
            echo -e "${YELLOW}已将服务 $service_443 的端口修改为 $new_port_443。${RESET}"
            # 更新服务的端口配置（假设服务是 Nginx）
            sudo sed -i "s/listen 443/listen $new_port_443/g" /etc/nginx/sites-available/*
            sudo systemctl restart nginx
        fi
    fi

    # 提示用户输入域名
    read -p "请输入第一个域名（例如：example1.com）： " domain1
    read -p "请输入第二个域名（例如：example2.com）： " domain2

    # 配置 Nginx 反向代理
    echo -e "${YELLOW}正在配置 Nginx 反向代理...${RESET}"
    cat > /etc/nginx/sites-available/multi-site <<EOL
# 重定向HTTP到HTTPS
server {
    listen 80;
    server_name $domain1 $domain2;
    return 301 https://\$host\$request_uri;
}

# HTTPS配置 for $domain1
server {
    listen 443 ssl;
    server_name $domain1;

    ssl_certificate /etc/letsencrypt/live/$domain1/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$domain1/privkey.pem;

    location / {
        proxy_pass http://localhost:8080;  # 内部转发到 8080
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}

# HTTPS配置 for $domain2
server {
    listen 443 ssl;
    server_name $domain2;

    ssl_certificate /etc/letsencrypt/live/$domain2/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$domain2/privkey.pem;

    location / {
        proxy_pass http://localhost:8443;  # 内部转发到 8443
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOL

    # 启用站点配置
    sudo ln -s /etc/nginx/sites-available/multi-site /etc/nginx/sites-enabled/
    sudo nginx -t && sudo systemctl reload nginx

    # 申请 Let's Encrypt 证书
    echo -e "${YELLOW}正在申请 Let's Encrypt 证书...${RESET}"
    sudo certbot --nginx -d $domain1 --non-interactive --agree-tos -m admin@$domain1
    sudo certbot --nginx -d $domain2 --non-interactive --agree-tos -m admin@$domain2

    # 配置证书自动续期
    echo -e "${YELLOW}正在配置证书自动续期...${RESET}"
    (crontab -l 2>/dev/null; echo "0 0 * * * certbot renew --quiet && systemctl reload nginx") | crontab -

    # 重新启动被停止的服务
    if [ -n "$stopped_services" ]; then
        echo -e "${YELLOW}正在重新启动被停止的服务...${RESET}"
        for service in $stopped_services; do
            sudo systemctl enable $service
            sudo systemctl start $service
            echo -e "${GREEN}已重新启动服务 $service。${RESET}"
        done
    fi

    # 自动开放防火墙端口
    echo -e "${YELLOW}正在配置防火墙...${RESET}"
    if command -v ufw &> /dev/null; then
        echo -e "${GREEN}检测到 ufw，正在开放端口 80, 443, 8080, 8443...${RESET}"
        sudo ufw allow 80/tcp
        sudo ufw allow 443/tcp
        sudo ufw allow 8080/tcp
        sudo ufw allow 8443/tcp
        sudo ufw reload
    elif command -v firewall-cmd &> /dev/null; then
        echo -e "${GREEN}检测到 firewalld，正在开放端口 80, 443, 8080, 8443...${RESET}"
        sudo firewall-cmd --zone=public --add-port=80/tcp --permanent
        sudo firewall-cmd --zone=public --add-port=443/tcp --permanent
        sudo firewall-cmd --zone=public --add-port=8080/tcp --permanent
        sudo firewall-cmd --zone=public --add-port=8443/tcp --permanent
        sudo firewall-cmd --reload
    else
        echo -e "${RED}未检测到 ufw 或 firewalld，请手动开放端口 80, 443, 8080, 8443。${RESET}"
    fi

    echo -e "${GREEN}配置完成！${RESET}"
    echo -e "${YELLOW}您现在可以通过以下地址访问服务：${RESET}"
    echo -e "${YELLOW}https://$domain1${RESET}"
    echo -e "${YELLOW}https://$domain2${RESET}"
    ;;
    
17)
    # 脚本更新
    echo -e "${GREEN}正在更新脚本...${RESET}"
    wget -O /tmp/onekey.sh https://raw.githubusercontent.com/sinian-liu/onekey/main/onekey.sh
    if [ $? -eq 0 ]; then
        mv /tmp/onekey.sh /usr/local/bin/onekey.sh
        chmod +x /usr/local/bin/onekey.sh
        echo -e "${GREEN}脚本更新成功！${RESET}"
        echo -e "${YELLOW}请重新运行脚本以应用更新。${RESET}"
    else
        echo -e "${RED}脚本更新失败，请检查网络连接！${RESET}"
    fi
    ;;

*)
    echo -e "${RED}无效选项，请重新运行脚本并选择正确的选项。${RESET}"
    ;;
    
esac
