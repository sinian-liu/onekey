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
echo -e "${YELLOW}8. 一键永久禁用IPv6${RESET}"
echo -e "${YELLOW}9. 一键解除禁用IPv6${RESET}"
echo -e "${YELLOW}10.服务器时区修改为中国时区${RESET}"
echo -e "${YELLOW}11.保持SSH会话一直连接不断开${RESET}"
echo -e "${YELLOW}12.安装Windows或Linux系统${RESET}"
echo -e "${YELLOW}13.服务器对服务器文件传输${RESET}"
echo -e "${YELLOW}14.安装 NekoNekoStatus 服务器探针并绑定域名${RESET}"
echo -e "${GREEN}=============================================${RESET}"

read -p "请输入选项 [1-13]:" option

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

    9)
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

    10)
        # 服务器时区修改为中国时区
        echo -e "${GREEN}正在修改服务器时区为中国时区 ...${RESET}"
        sudo ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
        sudo service cron restart
        ;;

    11)
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

    12)
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

13)
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
    14)
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
    read -p "请输入您的域名（例如：server.1373737.xyz）： " domain
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
    echo -e "${YELLOW}您现在可以通过 https://$domain 访问 NekoNekoStatus。${RESET}"
    echo -e "${YELLOW}容器端口: $container_port${RESET}"
    echo -e "${YELLOW}反向代理端口: $proxy_port${RESET}"
    echo -e "${YELLOW}默认密码: nekonekostatus${RESET}"
    echo -e "${YELLOW}安装后务必修改密码！${RESET}"
    ;;
    
esac
