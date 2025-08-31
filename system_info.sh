#!/bin/bash
# 设置环境变量以确保 UTF-8 编码
export LC_ALL=C.UTF-8
export LANG=C.UTF-8

# 检查是否为首次运行
FIRST_RUN_FLAG="/root/.first_run_done"
if [ ! -f "$FIRST_RUN_FLAG" ]; then
    # 更新系统
    update_system() {
        echo "正在检查并更新系统..."
        if [[ -f /etc/debian_version ]]; then
            sudo apt update && sudo apt upgrade -y
        elif [[ -f /etc/redhat-release ]]; then
            sudo yum install -y epel-release
            sudo yum update -y
        else
            echo "未知的系统类型，跳过更新。"
        fi
    }
    update_system

    # 安装常用依赖
    install_required_tools() {
        echo "检查并安装缺少的工具..."
        local tools=("jq" "curl" "coreutils" "fio" "tar" "iperf3" "mtr" "wget" "unzip" "zip" "net-tools" "bc" "wkhtmltopdf")
        for tool in "${tools[@]}"; do
            if ! command -v "${tool%% *}" &>/dev/null; then
                echo "$tool 未安装，正在安装..."
                if [[ -f /etc/debian_version ]]; then
                    sudo apt install -y "$tool"
                elif [[ -f /etc/redhat-release ]]; then
                    sudo yum install -y "$tool"
                fi
            else
                echo "$tool 已安装。"
            fi
        done
        # 安装 lsb-release
        if ! command -v lsb_release &>/dev/null; then
            echo "lsb-release 未安装，正在安装..."
            if [[ -f /etc/debian_version ]]; then
                sudo apt install -y lsb-release
            elif [[ -f /etc/redhat-release ]]; then
                sudo yum install -y redhat-lsb-core
            fi
        else
            echo "lsb-release 已安装。"
        fi
        # 安装 Python
        if ! command -v python3 &>/dev/null; then
            echo "Python 未安装，正在安装..."
            if [[ -f /etc/debian_version ]]; then
                sudo apt install -y python3
            elif [[ -f /etc/redhat-release ]]; then
                sudo yum install -y python3
            fi
        else
            echo "Python 已安装。"
        fi
        # 安装中文字体
        if [[ -f /etc/debian_version ]]; then
            if ! dpkg -l | grep -q fonts-noto-cjk; then
                echo "中文字体未安装，正在安装 fonts-noto-cjk..."
                sudo apt install -y fonts-noto-cjk
            else
                echo "中文字体 fonts-noto-cjk 已安装。"
            fi
        elif [[ -f /etc/redhat-release ]]; then
            if ! rpm -q google-noto-sans-cjk-fonts &>/dev/null; then
                echo "中文字体未安装，正在安装 google-noto-sans-cjk-fonts..."
                sudo yum install -y google-noto-sans-cjk-fonts
            else
                echo "中文字体 google-noto-sans-cjk-fonts 已安装。"
            fi
        fi
    }
    install_required_tools

    # 创建标志文件
    touch "$FIRST_RUN_FLAG"
else
    echo "非首次运行，跳过系统更新和依赖安装。"
fi

# 后台心跳运行
while true; do
    echo "$(date '+%Y-%m-%d %H:%M:%S') Heartbeat" >> /var/log/heartbeat.log
    sleep 120
done &

# 捕获所有输出到日志文件
LOG_FILE="/root/test_log.txt"
rm -f "$LOG_FILE"
script -q -c "bash -c '$(cat <<'EOF'
# 内部脚本内容
# 记录开始时间
start_time=$(date +%s)
# 设置快捷命令
if ! grep -q "alias sn=" ~/.bashrc; then
    echo "正在为 sn 设置快捷命令..."
    echo "alias sn='bash <(curl -sL https://raw.githubusercontent.com/sinian-liu/VPStest/main/system_info.sh)'" >> ~/.bashrc
    source ~/.bashrc
    echo "快捷命令 sn 已设置。"
else
    echo "快捷命令 sn 已经存在。"
fi
# 设置主机名
NEW_HOSTNAME="www.1373737.xyz"
sudo hostnamectl set-hostname "$NEW_HOSTNAME"
sudo sed -i "s/127.0.1.1.*/127.0.1.1 $NEW_HOSTNAME/" /etc/hosts
echo "主机名已成功修改为："
hostnamectl
# 设置时区
set_timezone_to_shanghai() {
    echo "正在将系统时区设置为中国上海..."
    sudo timedatectl set-timezone Asia/Shanghai
    echo "当前系统时区为：$(timedatectl | grep 'Time zone' || echo 'N/A')"
}
# 检测系统类型
is_debian_or_ubuntu() {
    if [[ -f /etc/debian_version ]]; then
        echo "检测到Debian或Ubuntu系统，继续开启BBR..."
        return 0
    else
        echo "此系统不是Debian或Ubuntu，跳过BBR设置。"
        return 1
    fi
}
# 开启BBR
enable_bbr() {
    if is_debian_or_ubuntu; then
        echo "正在开启BBR..."
        echo "net.core.default_qdisc=fq" | sudo tee -a /etc/sysctl.conf
        echo "net.ipv4.tcp_congestion_control=bbr" | sudo tee -a /etc/sysctl.conf
        sudo sysctl -p
        sysctl net.ipv4.tcp_available_congestion_control
        lsmod | grep bbr
    fi
}
# 配置 iperf3 自动启动
enable_iperf3_autostart() {
    echo "正在配置 iperf3 为自动启动守护进程..."
    sudo bash -c 'cat > /etc/systemd/system/iperf3.service <<EOF
[Unit]
Description=iperf3 Daemon
After=network.target
[Service]
ExecStart=/usr/bin/iperf3 -s
Restart=on-failure
User=nobody
Group=nogroup
[Install]
WantedBy=multi-user.target
EOF'
    sudo systemctl daemon-reload
    sudo systemctl start iperf3
    sudo systemctl enable iperf3
    echo "iperf3 服务已配置为自动启动。"
}
# 执行系统设置
set_timezone_to_shanghai
enable_bbr
enable_iperf3_autostart
# 颜色定义
YELLOW='\033[1;33m'
NC='\033[0m'
# 系统信息
hostname=$(hostname)
domain=$(hostname -d 2>/dev/null || echo "N/A")
os_version=$(lsb_release -d 2>/dev/null | awk -F"\t" '{print $2}' || echo "N/A")
kernel_version=$(uname -r)
cpu_arch=$(uname -m)
cpu_model=$(awk -F': ' '/model name/ {print $2; exit}' /proc/cpuinfo | xargs || echo "N/A")
cpu_cores=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || echo "N/A")
cpu_frequency=$(awk -F': ' '/cpu MHz/ {print $2; exit}' /proc/cpuinfo | awk '{printf "%.4f GHz", $1 / 1000}' 2>/dev/null || echo "N/A")
cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{printf "%.1f%%", $2 + $4}' 2>/dev/null || echo "N/A")
load_avg=$(uptime | awk -F'load average: ' '{print $2}' 2>/dev/null || echo "N/A")
memory_usage=$(free -m | awk '/Mem:/ {printf "%.2f/%.2f MB (%.2f%%)", $3, $2, $3/$2 * 100}' 2>/dev/null || echo "N/A")
swap_usage=$(free -m | awk '/Swap:/ {if ($2 > 0) printf "%.2f/%.2f MB (%.2f%%)", $3, $2, $3/$2 * 100; else print "N/A"}' 2>/dev/null || echo "N/A")
disk_usage=$(df -h / | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}' 2>/dev/null || echo "N/A")
get_network_traffic() {
    local bytes=$1
    if [ -n "$bytes" ] && (( bytes > 1024*1024*1024 )); then
        echo "$(awk "BEGIN {printf \"%.2f GB\", $bytes/1024/1024/1024}")"
    elif [ -n "$bytes" ] && (( bytes > 1024*1024 )); then
        echo "$(awk "BEGIN {printf \"%.2f MB\", $bytes/1024/1024}")"
    elif [ -n "$bytes" ]; then
        echo "$(awk "BEGIN {printf \"%.2f KB\", $bytes/1024}")"
    else
        echo "0 KB"
    fi
}
interface=$(ip route | grep '^default' | awk '{print $5}' 2>/dev/null || echo "N/A")
total_rx=$(get_network_traffic $(cat /proc/net/dev | grep -w "$interface" | awk '{print $2}' 2>/dev/null || echo 0))
total_tx=$(get_network_traffic $(cat /proc/net/dev | grep -w "$interface" | awk '{print $10}' 2>/dev/null || echo 0))
tcp_algo=$(sysctl -n net.ipv4.tcp_congestion_control 2>/dev/null || echo "N/A")
ip_info=$(curl -s ipinfo.io || echo "{}")
ipv4=$(echo "$ip_info" | jq -r '.ip // "N/A"')
isp=$(echo "$ip_info" | jq -r '.org // "N/A"')
location=$(echo "$ip_info" | jq -r '.city + ", " + .country' 2>/dev/null || echo "N/A")
dns_address=$(awk '/^nameserver/ {print $2}' /etc/resolv.conf | tr '\n' ' ' | xargs 2>/dev/null || echo "N/A")
timezone=$(timedatectl | grep "Time zone" | awk '{print $3}' 2>/dev/null || echo "N/A")
sys_time=$(date "+%Y-%m-%d %H:%M %p")
uptime_seconds=$(cat /proc/uptime | awk '{print int($1)}' 2>/dev/null || echo 0)
uptime_days=$((uptime_seconds / 86400))
uptime_hours=$(( (uptime_seconds % 86400) / 3600 ))
uptime_minutes=$(( (uptime_seconds % 3600) / 60 ))
if (( uptime_days > 0 )); then
    uptime_formatted="${uptime_days}天 ${uptime_hours}时 ${uptime_minutes}分"
else
    uptime_formatted="${uptime_hours}时 ${uptime_minutes}分"
fi
echo -e "\n${YELLOW}系统信息查询${NC}"
echo "-------------"
echo "主机名: $hostname.$domain"
echo "系统版本: $os_version"
echo "Linux版本: $kernel_version"
echo "-------------"
echo "CPU架构: $cpu_arch"
echo "CPU型号: $cpu_model"
echo "CPU核心数: $cpu_cores"
echo "CPU频率: $cpu_frequency"
echo "-------------"
echo "CPU占用: $cpu_usage"
echo "系统负载: $load_avg"
echo "物理内存: $memory_usage"
echo "虚拟内存: $swap_usage"
echo "硬盘占用: $disk_usage"
echo "-------------"
echo "总接收: $total_rx"
echo "总发送: $total_tx"
echo "-------------"
echo "网络算法: $tcp_algo"
echo "-------------"
echo "运营商: $isp"
echo "IPv4地址: $ipv4"
echo "DNS地址: $dns_address"
echo "地理位置: $location"
echo "系统时间: $timezone $sys_time"
echo "-------------"
echo "运行时长: $uptime_formatted"
# 颜色定义
YELLOW='\033[1;33m'
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'
_yellow() { echo -e "${YELLOW}$1${NC}"; }
_red() { echo -e "${RED}$1${NC}"; }
# 硬盘 I/O 测试
io_test() {
    result=$(dd if=/dev/zero of=tempfile bs=1M count=$1 oflag=direct 2>&1 | grep -oP '[0-9.]+ (MB|GB)/s' || echo "N/A")
    rm -f tempfile
    echo "$result"
}
print_io_test() {
    freespace=$(df -m . | awk 'NR==2 {print $4}' || echo 0)
    if [ -z "${freespace}" ]; then
        freespace=$(df -m . | awk 'NR==3 {print $3}' || echo 0)
    fi
    if [ "${freespace}" -gt 1024 ]; then
        writemb=2048
        echo -e "\n\n\n${YELLOW}硬盘 I/O 性能测试${NC}\n"
        echo "硬盘性能测试正在进行中..."
        io1=$(io_test ${writemb})
        io2=$(io_test ${writemb})
        io3=$(io_test ${writemb})
        ioraw1=$(echo "$io1" | awk '{print $1}' || echo 0)
        [[ "$(echo "$io1" | awk '{print $2}')" == "GB/s" ]] && ioraw1=$(awk 'BEGIN{print '"$ioraw1"' * 1024}')
        ioraw2=$(echo "$io2" | awk '{print $1}' || echo 0)
        [[ "$(echo "$io2" | awk '{print $2}')" == "GB/s" ]] && ioraw2=$(awk 'BEGIN{print '"$ioraw2"' * 1024}')
        ioraw3=$(echo "$io3" | awk '{print $1}' || echo 0)
        [[ "$(echo "$io3" | awk '{print $2}')" == "GB/s" ]] && ioraw3=$(awk 'BEGIN{print '"$ioraw3"' * 1024}')
        ioall=$(awk 'BEGIN{print '"$ioraw1"' + '"$ioraw2"' + '"$ioraw3"'}')
        ioavg=$(awk 'BEGIN{printf "%.2f", '"$ioall"' / 3}' 2>/dev/null || echo "N/A")
        echo -e "\n硬盘性能测试结果如下："
        printf "%-25s %s\n" "硬盘I/O (第一次测试) :" "$(_yellow "$io1")"
        printf "%-25s %s\n" "硬盘I/O (第二次测试) :" "$(_yellow "$io2")"
        printf "%-25s %s\n" "硬盘I/O (第三次测试) :" "$(_yellow "$io3")"
        echo -e "硬盘I/O (平均测试) : $(_yellow "$ioavg MB/s")"
        disk_type=$(lsblk -d -o name,rota | awk 'NR==2 {print $2}' 2>/dev/null || echo "N/A")
        disk_device=$(lsblk -d -o name,rota | awk 'NR==2 {print $1}' 2>/dev/null || echo "N/A")
        if [[ "$disk_device" == nvme* ]]; then
            disk_type="NVMe SSD"
        elif [[ "$disk_type" == "0" ]]; then
            disk_type="SSD"
        elif [[ "$disk_type" == "1" ]]; then
            disk_type="HDD"
        else
            disk_type="未知"
        fi
        if [[ "$ioavg" != "N/A" ]] && (( $(echo "$ioavg > 500" | bc -l 2>/dev/null || echo 0) )); then
            performance_level="优秀"
        elif [[ "$ioavg" != "N/A" ]] && (( $(echo "$ioavg > 200" | bc -l 2>/dev/null || echo 0) )); then
            performance_level="好"
        elif [[ "$ioavg" != "N/A" ]] && (( $(echo "$ioavg > 100" | bc -l 2>/dev/null || echo 0) )); then
            performance_level="一般"
        else
            performance_level="差"
        fi
        echo "硬盘类型: $disk_type"
        echo "硬盘性能等级: $performance_level"
        echo -e "${GREEN}测试数据不是百分百准确，以官方宣称为主。${NC}"
    else
        echo -e " $(_red "空间不足，无法测试硬盘性能！")"
    fi
}
print_io_test
# IPinfo 查询
API_TOKEN="5ebf2ff2b04160"
echo "正在执行 IPinfo 查询..."
ip_info=$(curl -s "ipinfo.io?token=${API_TOKEN}" || echo "{}")
ip_address=$(echo "$ip_info" | jq -r '.ip // "N/A"')
city=$(echo "$ip_info" | jq -r '.city // "N/A"')
region=$(echo "$ip_info" | jq -r '.region // "N/A"')
country=$(echo "$ip_info" | jq -r '.country // "N/A"')
loc=$(echo "$ip_info" | jq -r '.loc // "N/A"')
org=$(echo "$ip_info" | jq -r '.org // "N/A"')
asn=$(echo "$ip_info" | jq -r '.org // "N/A"')
company_name="N/A"
company_domain="N/A"
company_type="N/A"
echo -e "\n\n\nIP info信息查询结果如下："
echo "-------------------"
echo "IP 地址: $ip_address"
echo "城市: $city"
echo "地区: $region"
echo "国家: $country"
echo "地理位置: $loc"
echo "组织: $org"
echo "-------------------"
echo "ASN编号: $asn"
echo "-------------------"
echo "公司名称: $company_name"
echo "公司域名: $company_domain"
echo "公司类型: $company_type"
echo -e "\n\n备注："
echo "1. ASN 编号、名称、路由和类型字段仅在付费版本中可用。"
echo "2. 公司信息（名称、域名、类型）仅在付费版本中可用。"
# IP 欺诈风险检测
API_KEY="89c1e8dc1272cb7b1e1f162cbdcc0cf4434a06c41b4ab7f8b7f9497c0cd56e9f"
check_dependencies() {
    echo "检测所需依赖工具：curl 和 jq..."
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
    else
        echo "无法检测系统类型，请手动安装 curl 和 jq 后重试。"
        exit 1
    fi
    if ! command -v curl &> /dev/null; then
        echo "未检测到 curl，正在安装..."
        if [[ "$OS" == "ubuntu" || "$OS" == "debian" ]]; then
            sudo apt update && sudo apt install -y curl
        elif [[ "$OS" == "centos" || "$OS" == "rocky" || "$OS" == "almalinux" ]]; then
            sudo yum install -y curl
        else
            echo "不支持的系统类型：$OS，请手动安装 curl 后重试。"
            exit 1
        fi
    else
        echo "curl 已安装，跳过。"
    fi
    if ! command -v jq &> /dev/null; then
        echo "未检测到 jq，正在安装..."
        if [[ "$OS" == "ubuntu" || "$OS" == "debian" ]]; then
            sudo apt update && sudo apt install -y jq
        elif [[ "$OS" == "centos" || "$OS" == "rocky" || "$OS" == "almalinux" ]]; then
            sudo yum install -y jq
        else
            echo "不支持的系统类型：$OS，请手动安装 jq 后重试。"
            exit 1
        fi
    else
        echo "jq 已安装，跳过。"
    fi
}
get_current_time() {
    date +"%Y-%m-%d %H:%M:%S"
}
get_public_ip() {
    IPV4=$(curl -s https://api.ipify.org)
    if [[ -n "$IPV4" ]]; then
        echo $IPV4
    else
        echo "无法获取公网IPv4地址"
        exit 1
    fi
}
get_fraud_details() {
    IP=$1
    RESPONSE=$(curl -s "https://api.scamalytics.com/v1/score/$IP?api_key=$API_KEY")
    SCORE=$(echo $RESPONSE | jq -r '.score // "null"')
    RISK=$(echo $RESPONSE | jq -r '.risk // "unknown"')
    if [[ "$SCORE" == "null" || -z "$SCORE" ]]; then
        echo "API响应不包含有效得分，无法继续检测。"
        exit 1
    fi
    echo "$SCORE $RISK"
}
display_fraud_score() {
    IP=$1
    SCORE=$2
    RISK=$3
    CURRENT_TIME=$(get_current_time)
    echo -e "\n检测时间: $CURRENT_TIME"
    echo -e "此 IP ($IP) 的欺诈得分为 $SCORE，风险等级评估：\c"
    if [[ "$RISK" == "low" ]]; then
        echo -e "\033[32m低风险\033[0m。"
    elif [[ "$RISK" == "medium" ]]; then
        echo -e "\033[33m中等风险\033[0m。"
    elif [[ "$RISK" == "high" ]]; then
        echo -e "\033[31m高风险！\033[0m"
    else
        echo -e "\033[34m未知风险\033[0m。"
    fi
}
main() {
    check_dependencies
    IP=$(get_public_ip)
    echo -e "正在检测当前VPS的公网 IPv4: $IP"
    DETAILS=$(get_fraud_details $IP)
    FRAUD_SCORE=$(echo $DETAILS | awk '{print $1}')
    RISK_LEVEL=$(echo $DETAILS | awk '{print $2}')
    display_fraud_score $IP $FRAUD_SCORE $RISK_LEVEL
}
# 执行外部测试脚本
echo -e "\n${YELLOW}执行外部测试脚本${NC}"
echo "正在执行 IP 质量检测..."
bash <(curl -Ls IP.Check.Place) <<< "y" 2>&1 || echo "IP.Check.Place 执行失败"
echo "正在执行第一个三网回程线路测试..."
curl https://raw.githubusercontent.com/zhanghanyun/backtrace/main/install.sh -sSf | sh 2>&1 || echo "backtrace 执行失败"
echo "正在执行第二个三网回程线路测试..."
curl https://raw.githubusercontent.com/zhucaidan/mtr_trace/main/mtr_trace.sh | bash 2>&1 || echo "mtr_trace 执行失败"
echo "正在执行三网+教育网 IPv4 单线程测速..."
bash <(curl -sL https://raw.githubusercontent.com/i-abc/Speedtest/main/speedtest.sh) <<< "2" 2>&1 || echo "speedtest.sh 执行失败"
echo "正在执行流媒体平台及游戏区域限制测试..."
bash <(curl -L -s check.unlock.media) <<< "66" 2>&1 || echo "check.unlock.media 执行失败"
echo "正在执行全国五网ISP路由回程测试..."
curl -s https://nxtrace.org/nt | bash && sleep 2 && echo -e "1\n6" | nexttrace --fast-trace 2>&1 || echo "nexttrace 执行失败"
echo "正在执行 Bench 性能测试..."
curl -Lso- bench.sh | bash 2>&1 || echo "bench.sh 执行失败"
echo ""
echo ""
# 显示测试完成提示
echo -e "\n\033[33m37VPS主机评测：\033[31mhttps://1373737.xyz\033[0m"
echo -e "\033[33m服务器推荐：\033[31mhttps://my.frantech.ca/aff.php?aff=4337\033[0m"
echo -e "\033[33mYouTube频道：\033[31mhttps://www.youtube.com/@cyndiboy7881\033[0m"
echo -e "\033[33mv2ray-agent脚本：\033[31mhttps://github.com/sinian-liu/v2ray-agent\033[0m"
# 计算总耗时
end_time=$(date +%s)
elapsed_time=$((end_time - start_time))
minutes=$((elapsed_time / 60))
seconds=$((elapsed_time % 60))
if [ $minutes -gt 0 ]; then
    echo -e "\033[33m所有测试已经完成，测试总耗时：\033[31m${minutes} 分钟 ${seconds} 秒\033[33m，感谢使用本脚本。\033[0m"
else
    echo -e "\033[33m所有测试已经完成，测试总耗时：\033[31m${seconds} 秒\033[33m，感谢使用本脚本。\033[0m"
fi
echo -e "\033[33m下次直接输入快捷命令即可再次启动：\033[31msn\033[0m"
EOF
)'" "$LOG_FILE"

# 清理日志中的 ANSI 颜色代码
sed -i 's/\x1B\[[0-9;]*[mK]//g' "$LOG_FILE"

# 生成 HTML 报告
REPORT_FILE="/root/test_report.html"
cat <<EOF > "$REPORT_FILE"
<html>
<head>
    <title>VPS Test Report</title>
    <meta charset="UTF-8">
    <style>
        body {
            font-family: 'Noto Sans CJK SC', monospace;
            background-color: #2e2e2e;
            color: #ffffff;
            margin: 20px;
            padding: 20px;
        }
        pre {
            background-color: #1a1a1a;
            padding: 15px;
            border-radius: 5px;
            white-space: pre-wrap;
            word-wrap: break-word;
        }
        h1 {
            color: #f0c674;
        }
    </style>
</head>
<body>
    <h1>VPS 测试报告</h1>
    <pre>
$(cat "$LOG_FILE")
    </pre>
</body>
</html>
EOF
echo "HTML 报告已生成：$REPORT_FILE"

# 生成图片报告
IMAGE_FILE="/root/test_report.png"
if command -v wkhtmltoimage &>/dev/null; then
    echo "正在生成图片报告..."
    wkhtmltoimage --width 1200 --quality 90 "$REPORT_FILE" "$IMAGE_FILE" 2>/dev/null
    if [ -f "$IMAGE_FILE" ]; then
        echo "图片报告已生成：$IMAGE_FILE"
    else
        echo "生成图片报告失败，请检查 wkhtmltoimage 是否正确安装。"
    fi
else
    echo "wkhtmltoimage 未安装，跳过图片报告生成。"
fi

# 启动 Web 服务器
PORT=8000
if [[ -f /etc/debian_version ]]; then
    command -v ufw >/dev/null 2>&1 && sudo ufw allow $PORT
elif [[ -f /etc/redhat-release ]]; then
    command -v firewall-cmd >/dev/null 2>&1 && {
        sudo firewall-cmd --permanent --add-port=$PORT/tcp
        sudo firewall-cmd --reload
    }
fi
cd /root
nohup python3 -m http.server $PORT --bind 0.0.0.0 > /dev/null 2>&1 &
PUBLIC_IP=$(curl -s https://api.ipify.org)
if [[ -n "$PUBLIC_IP" ]]; then
    echo "图片报告可以通过以下网址下载：http://$PUBLIC_IP:$PORT/test_report.png"
    echo "HTML 报告可以通过以下网址查看：http://$PUBLIC_IP:$PORT/test_report.html"
else
    echo "无法获取公网 IP，报告已生成在 $REPORT_FILE 和 $IMAGE_FILE，请手动下载。"
fi
