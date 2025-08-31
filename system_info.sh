#!/bin/bash
# 设置环境变量以确保 UTF-8 编码
export LC_ALL=C.UTF-8
export LANG=C.UTF-8

# 检查是否为首次运行
FIRST_RUN_FLAG="/root/.first_run_done"
if [ ! -f "$FIRST_RUN_FLAG" ]; then
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

    install_required_tools() {
        echo "检查并安装缺少的工具..."
        local tools=("jq" "curl" "coreutils" "fio" "tar" "iperf3" "mtr" "wget" "unzip" "zip" "net-tools" "bc" "wkhtmltopdf" "pngquant")
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
        if ! command -v lsb_release &>/dev/null; then
            echo "lsb-release 未安装，正在安装..."
            if [[ -f /etc/debian_version ]]; then
                sudo apt install -y lsb-release
            elif [[ -f /etc/redhat-release ]]; then
                sudo yum install -y redhat-lsb-core
            fi
        fi
        if [[ -f /etc/debian_version ]]; then
            if ! dpkg -l | grep -q fonts-noto-cjk; then
                sudo apt install -y fonts-noto-cjk
            fi
        elif [[ -f /etc/redhat-release ]]; then
            if ! rpm -q google-noto-sans-cjk-fonts &>/dev/null; then
                sudo yum install -y google-noto-sans-cjk-fonts
            fi
        fi
    }
    install_required_tools

    touch "$FIRST_RUN_FLAG"
fi

# 后台心跳运行
while true; do
    echo "$(date '+%Y-%m-%d %H:%M:%S') Heartbeat" >> /var/log/heartbeat.log
    sleep 120
done &

# 捕获所有输出到日志文件
LOG_FILE="/root/test_log.txt"
rm -f "$LOG_FILE"
exec > >(tee -a "$LOG_FILE") 2>&1

# 检查 DNS 配置
check_dns() {
    echo "检查系统 DNS 配置..."
    if [ -s /etc/resolv.conf ]; then
        echo "当前 DNS 服务器："
        cat /etc/resolv.conf | grep nameserver
        if ! nslookup google.com >/dev/null 2>&1; then
            echo "DNS 解析失败，尝试配置备用 DNS..."
            sudo bash -c 'echo "nameserver 8.8.8.8" > /etc/resolv.conf'
            sudo bash -c 'echo "nameserver 1.1.1.1" >> /etc/resolv.conf'
            if ! nslookup google.com >/dev/null 2>&1; then
                echo "备用 DNS 仍然无法解析，请检查网络连接或防火墙（UDP 53 端口）。"
                return 1
            fi
        fi
    else
        echo "DNS 配置文件 /etc/resolv.conf 为空，配置备用 DNS..."
        sudo bash -c 'echo "nameserver 8.8.8.8" > /etc/resolv.conf'
        sudo bash -c 'echo "nameserver 1.1.1.1" >> /etc/resolv.conf'
        if ! nslookup google.com >/dev/null 2>&1; then
            echo "备用 DNS 仍然无法解析，请检查网络连接或防火墙（UDP 53 端口）。"
            return 1
        fi
    fi
    return 0
}
check_dns || echo "警告：DNS 配置有问题，可能影响测试."

# 内部脚本内容
start_time=$(date +%s)

# 设置快捷命令
if ! grep -q "alias sn=" ~/.bashrc; then
    echo "alias sn='bash <(curl -sL https://raw.githubusercontent.com/sinian-liu/VPStest/main/system_info.sh)'" >> ~/.bashrc
    source ~/.bashrc
fi

# 设置主机名
NEW_HOSTNAME="www.1373737.xyz"
sudo hostnamectl set-hostname "$NEW_HOSTNAME"
sudo sed -i "s/127.0.1.1.*/127.0.1.1 $NEW_HOSTNAME/" /etc/hosts
echo "主机名已修改为："
hostnamectl

# 设置时区
sudo timedatectl set-timezone Asia/Shanghai
echo "当前系统时区为：$(timedatectl | grep 'Time zone')"

# 检测系统类型并开启 BBR
is_debian_or_ubuntu() {
    [[ -f /etc/debian_version ]]
}
if is_debian_or_ubuntu; then
    echo "net.core.default_qdisc=fq" | sudo tee -a /etc/sysctl.conf
    echo "net.ipv4.tcp_congestion_control=bbr" | sudo tee -a /etc/sysctl.conf
    sudo sysctl -p
    sysctl net.ipv4.tcp_available_congestion_control
    lsmod | grep bbr
fi

# 配置 iperf3 自动启动
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

# 颜色定义
YELLOW='\033[1;33m'
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'
_yellow() { echo -e "${YELLOW}$1${NC}"; }
_red() { echo -e "${RED}$1${NC}"; }
_green() { echo -e "${GREEN}$1${NC}"; }

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
interface=$(ip route | grep '^default' | awk '{print $5}' 2>/dev/null || echo "N/A")
total_rx=$(awk 'BEGIN {printf "%.2f GB", $(cat /proc/net/dev | grep -w "'$interface'" | awk '{print $2}') / 1024 / 1024 / 1024}' 2>/dev/null || echo "N/A")
total_tx=$(awk 'BEGIN {printf "%.2f GB", $(cat /proc/net/dev | grep -w "'$interface'" | awk '{print $10}') / 1024 / 1024 / 1024}' 2>/dev/null || echo "N/A")
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
uptime_formatted="${uptime_days}天 ${uptime_hours}时 ${uptime_minutes}分"

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

io_test() {
    local count=$1
    result=$(dd if=/dev/zero of=tempfile bs=1M count=$count oflag=direct 2>&1 | grep -oP '[0-9.]+ (MB|GB)/s' || echo "N/A")
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
        [[ "$(echo "$io1" | awk '{print $2}')" == "GB/s" ]] && ioraw1=$(awk "BEGIN {print $ioraw1 * 1024}")
        ioraw2=$(echo "$io2" | awk '{print $1}' || echo 0)
        [[ "$(echo "$io2" | awk '{print $2}')" == "GB/s" ]] && ioraw2=$(awk "BEGIN {print $ioraw2 * 1024}")
        ioraw3=$(echo "$io3" | awk '{print $1}' || echo 0)
        [[ "$(echo "$io3" | awk '{print $2}')" == "GB/s" ]] && ioraw3=$(awk "BEGIN {print $ioraw3 * 1024}")
        ioall=$(awk "BEGIN {print $ioraw1 + $ioraw2 + $ioraw3}")
        ioavg=$(awk "BEGIN {printf \"%.2f\", $ioall / 3}" 2>/dev/null || echo "N/A")
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
        if [[ "$ioavg" != "N/A" ]] && [ "$(echo "$ioavg > 500" | bc -l)" -eq 1 ]; then
            performance_level="优秀"
        elif [[ "$ioavg" != "N/A" ]] && [ "$(echo "$ioavg > 200" | bc -l)" -eq 1 ]; then
            performance_level="好"
        elif [[ "$ioavg" != "N/A" ]] && [ "$(echo "$ioavg > 100" | bc -l)" -eq 1 ]; then
            performance_level="一般"
        else
            performance_level="差"
        fi
        echo "硬盘类型: $disk_type"
        echo "硬盘性能等级: $performance_level"
        echo -e "${GREEN}测试数据不是百分百准确，以官方宣称为主。${NC}"
    else
        echo -e "$(_red "空间不足，无法测试硬盘性能！")"
    fi
}
print_io_test

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
echo "2. 公司信息（名称、域名、类型）仅在付费版本中可用."

API_KEY="89c1e8dc1272cb7b1e1f162cbdcc0cf4434a06c41b4ab7f8b7f9497c0cd56e9f"
get_current_time() {
    date +"%Y-%m-%d %H:%M:%S"
}
get_public_ip() {
    IPV4=$(curl -s https://api.ipify.org)
    if [[ -n "$IPV4" ]]; then
        echo "$IPV4"
    else
        echo "无法获取公网IPv4地址"
        exit 1
    fi
}
get_fraud_details() {
    IP=$1
    RESPONSE=$(curl -s "https://api.scamalytics.com/v1/score/$IP?api_key=$API_KEY")
    SCORE=$(echo "$RESPONSE" | jq -r '.score // "null"')
    RISK=$(echo "$RESPONSE" | jq -r '.risk // "unknown"')
    if [[ "$SCORE" == "null" || -z "$SCORE" ]]; then
        echo "API响应不包含有效得分，无法继续检测."
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
        echo -e "${GREEN}低风险${NC}."
    elif [[ "$RISK" == "medium" ]]; then
        echo -e "${YELLOW}中等风险${NC}."
    elif [[ "$RISK" == "high" ]]; then
        echo -e "${RED}高风险！${NC}"
    else
        echo -e "\033[34m未知风险${NC}."
    fi
}
check_dependencies() {
    if ! command -v curl &> /dev/null; then
        echo "未检测到 curl，正在安装..."
        if [[ -f /etc/debian_version ]]; then
            sudo apt update && sudo apt install -y curl
        elif [[ -f /etc/redhat-release ]]; then
            sudo yum install -y curl
        fi
    fi
    if ! command -v jq &> /dev/null; then
        echo "未检测到 jq，正在安装..."
        if [[ -f /etc/debian_version ]]; then
            sudo apt update && sudo apt install -y jq
        elif [[ -f /etc/redhat-release ]]; then
            sudo yum install -y jq
        fi
    fi
}
check_dependencies
IP=$(get_public_ip)
echo -e "正在检测当前VPS的公网 IPv4: $IP"
DETAILS=$(get_fraud_details "$IP")
FRAUD_SCORE=$(echo "$DETAILS" | awk '{print $1}')
RISK_LEVEL=$(echo "$DETAILS" | awk '{print $2}')
display_fraud_score "$IP" "$FRAUD_SCORE" "$RISK_LEVEL"

# 执行外部测试脚本
echo -e "\n${YELLOW}执行外部测试脚本${NC}"
run_external_test() {
    local url=$1
    local cmd=$2
    local retries=3
    for i in $(seq 1 $retries); do
        if curl -sL "$url" -o /tmp/test_script.sh && chmod +x /tmp/test_script.sh && bash /tmp/test_script.sh $cmd 2>>"$EXTRACT_ERROR_LOG"; then
            return 0
        else
            echo "第 $i 次尝试 $url 失败，$((retries - i)) 次重试剩余..." >> "$EXTRACT_ERROR_LOG"
            sleep 2
        fi
    done
    echo "警告：$url 下载或执行失败。" >> "$EXTRACT_ERROR_LOG"
    return 1
}
run_external_test "https://raw.githubusercontent.com/i-abc/Speedtest/main/speedtest.sh" <<< "2" || echo "三网+教育网 IPv4 单线程测速未完成。"
run_external_test "https://nxtrace.org/nt" "&& sleep 2 && echo -e '1\n6' | nexttrace --fast-trace" || echo "全国五网ISP路由回程测试未完成。"
run_external_test "https://raw.githubusercontent.com/zhanghanyun/backtrace/main/install.sh" "" || echo "三网回程线路测试未完成。"
run_external_test "https://raw.githubusercontent.com/zhucaidan/mtr_trace/main/mtr_trace.sh" "" || echo "第二个三网回程线路测试未完成。"
run_external_test "https://check.unlock.media" <<< "66" || echo "流媒体平台及游戏区域限制测试未完成。"
run_external_test "https://raw.githubusercontent.com/teddysun/across/master/bench.sh" "" || echo "Bench 性能测试未完成."

echo -e "\n${YELLOW}37VPS主机评测：${NC}\033[31mhttps://1373737.xyz\033[0m"
echo -e "${YELLOW}服务器推荐：${NC}\033[31mhttps://my.frantech.ca/aff.php?aff=4337\033[0m"
echo -e "${YELLOW}YouTube频道：${NC}\033[31mhttps://www.youtube.com/@cyndiboy7881\033[0m"
echo -e "${YELLOW}v2ray-agent脚本：${NC}\033[31mhttps://github.com/sinian-liu/v2ray-agent\033[0m"

end_time=$(date +%s)
elapsed_time=$((end_time - start_time))
minutes=$((elapsed_time / 60))
seconds=$((elapsed_time % 60))
echo -e "${YELLOW}所有测试已经完成，测试总耗时：${NC}\033[31m${minutes} 分钟 ${seconds} 秒${NC}，感谢使用本脚本."

# 生成报告文件名
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
REPORT_FILE="/root/test_report_${TIMESTAMP}.html"
IMAGE_FILE="/root/test_report_${TIMESTAMP}.png"
EXTRACTED_REPORT_FILE="/root/extracted_report_${TIMESTAMP}.html"
EXTRACTED_IMAGE_FILE="/root/extracted_report_${TIMESTAMP}.png"
COMPRESSED_IMAGE_FILE="/root/extracted_report_compressed_${TIMESTAMP}.png"
EXTRACT_LOG="/root/extract_log_${TIMESTAMP}.txt"
EXTRACT_ERROR_LOG="/root/extract_report_error.log"

# 生成完整 HTML 报告
cat <<EOF > "$REPORT_FILE"
<html><head><title>VPS Test Report</title><meta charset="UTF-8"><style>body{font-family:'Noto Sans CJK SC',monospace;background-color:#2e2e2e;color:#ffffff;margin:20px;padding:20px;}pre{background-color:#1a1a1a;padding:15px;border-radius:5px;white-space:pre-wrap;word-wrap:break-word;}h1{color:#f0c674;}</style></head><body><h1>VPS 测试报告 (${TIMESTAMP})</h1><pre>$(cat "$LOG_FILE")</pre></body></html>
EOF
echo "完整 HTML 报告已生成：$REPORT_FILE"

if command -v wkhtmltoimage &>/dev/null; then
    echo "正在生成完整图片报告..."
    wkhtmltoimage --width 1200 --quality 90 "$REPORT_FILE" "$IMAGE_FILE" 2>/dev/null
    if [ -f "$IMAGE_FILE" ]; then
        echo "完整图片报告已生成：$IMAGE_FILE"
    else
        echo "生成完整图片报告失败，请检查 wkhtmltoimage。" >&2
    fi
fi

# 生成提取报告
echo "正在生成提取的测试报告..." >&2
rm -f "$EXTRACT_ERROR_LOG"
touch "$EXTRACT_ERROR_LOG"

if [ ! -f "$LOG_FILE" ]; then
    echo "错误：日志文件 $LOG_FILE 不存在。" >> "$EXTRACT_ERROR_LOG"
    exit 1
fi

> "$EXTRACT_LOG"
convert_ansi_to_html() {
    local line="$1"
    line="${line//\\033\[1;33m/<span style='color: #f0c674'>}"
    line="${line//\\033\[0;32m/<span style='color: #00ff00'>}"
    line="${line//\\033\[0;31m/<span style='color: #ff0000'>}"
    line="${line//\\033\[0m/<\/span>}"
    echo "$line"
}

extract_section() {
    local pattern=$1
    local end_pattern=$2
    if grep -A 50 "$pattern" "$LOG_FILE" | sed -n "/$pattern/,/$end_pattern/p" | while read -r line; do
        converted_line=$(convert_ansi_to_html "$line")
        echo "$converted_line" >> "$EXTRACT_LOG"
    done; then
        echo "" >> "$EXTRACT_LOG"
    else
        echo "警告：未匹配到 '$pattern' 部分。" >> "$EXTRACT_ERROR_LOG"
    fi
}

extract_section "系统信息查询" "运行时长:"
extract_section "硬盘 I/O 性能测试" "测试数据不是百分百准确，以官方宣称为主。"
extract_section "一、基础信息（Maxmind 数据库）" "使用地："
extract_section "二、IP类型属性" "公司类型："
extract_section "三、风险评分" "DB-IP："
extract_section "四、风险因子" "滥用："
extract_section "五、流媒体及AI服务解锁检测" "地区："
extract_section "六、邮局连通性及黑名单检测" "黑名单 [0-9]\+"
extract_section "项目地址: https://github.com/zhanghanyun/backtrace" "2025/[0-1][0-9]/[0-3][0-9] [0-2][0-9]:[0-5][0-9]:[0-5][0-9] 测试完成!"
extract_section "大陆三网\+教育网 IPv4 单线程测速" "电信 江苏南京 5G"
extract_section "============\[ Multination \]============" "Crave:"
extract_section "-------------------- A Bench.sh Script By Teddysun -------------------" "Timestamp :"

if [ ! -s "$EXTRACT_LOG" ]; then
    echo "错误：未提取到任何内容。" >> "$EXTRACT_ERROR_LOG"
    exit 1
fi

cat <<EOF > "$EXTRACTED_REPORT_FILE"
<html><head><title>Extracted VPS Test Report (${TIMESTAMP})</title><meta charset="UTF-8"><style>body{font-family:'Noto Sans CJK SC',monospace;background-color:#2e2e2e;color:#ffffff;margin:10px;padding:10px;font-size:10px;}pre{background-color:#1a1a1a;padding:10px;border-radius:5px;white-space:pre-wrap;word-wrap:break-word;max-height:none;overflow:auto;}h1{color:#f0c674;font-size:14px;}span{white-space:pre;}</style></head><body><h1>提取的 VPS 测试报告 (${TIMESTAMP})</h1><pre>$(cat "$EXTRACT_LOG")</pre></body></html>
EOF
echo "提取的 HTML 报告已生成：$EXTRACTED_REPORT_FILE" >&2

if command -v wkhtmltoimage &>/dev/null; then
    echo "正在生成提取的图片报告..." >&2
    wkhtmltoimage --width 600 --height 0 --zoom 2 --quality 90 "$EXTRACTED_REPORT_FILE" "$EXTRACTED_IMAGE_FILE" 2>>"$EXTRACT_ERROR_LOG"
    if [ -f "$EXTRACTED_IMAGE_FILE" ]; then
        echo "提取的图片报告已生成：$EXTRACTED_IMAGE_FILE" >&2
    else
        echo "生成提取的图片报告失败。" >> "$EXTRACT_ERROR_LOG"
    fi
fi

if command -v pngquant &>/dev/null; then
    echo "正在压缩提取的图片报告..." >&2
    pngquant --quality=40-60 --strip "$EXTRACTED_IMAGE_FILE" -o "$COMPRESSED_IMAGE_FILE" 2>>"$EXTRACT_ERROR_LOG"
    if [ -f "$COMPRESSED_IMAGE_FILE" ]; then
        echo "压缩后的提取图片报告已生成：$COMPRESSED_IMAGE_FILE" >&2
    fi
else
    cp "$EXTRACTED_IMAGE_FILE" "$COMPRESSED_IMAGE_FILE" 2>>"$EXTRACT_ERROR_LOG"
fi

chmod 644 "$EXTRACTED_REPORT_FILE" "$EXTRACTED_IMAGE_FILE" "$COMPRESSED_IMAGE_FILE" 2>/dev/null
ls -t /root/extracted_report_*.{html,png} 2>/dev/null | tail -n +11 | xargs -I {} rm -f {}

PORT=8000
pkill -f "python3 -m http.server $PORT" 2>/dev/null
nohup python3 -m http.server $PORT --bind 0.0.0.0 > /dev/null 2>&1 &
PUBLIC_IP=$(curl -s https://api.ipify.org)
if [[ -n "$PUBLIC_IP" ]]; then
    echo "报告网址：http://$PUBLIC_IP:$PORT/test_report_${TIMESTAMP}.{html,png}"
    echo "提取报告网址：http://$PUBLIC_IP:$PORT/extracted_report_${TIMESTAMP}.{html,png}"
    echo "压缩提取报告网址：http://$PUBLIC_IP:$PORT/extracted_report_compressed_${TIMESTAMP}.png"
else
    echo "报告已生成在 $REPORT_FILE, $IMAGE_FILE, $EXTRACTED_REPORT_FILE, $EXTRACTED_IMAGE_FILE, $COMPRESSED_IMAGE_FILE。"
fi
