# 一、项目介绍

## 脚本包含以下的功能


请选择要执行的操作：

0. 脚本更新
1. VPS一键测试
2. 安装BBR
3. 安装v2ray
4. 安装无人直播云SRS
5. 安装宝塔纯净版
6. 系统更新
7. 修改密码
8. 重启服务器
9. 一键永久禁用IPv6
10. 一键解除禁用IPv6
11. 服务器时区修改为中国时区
12. 保持SSH会话一直连接不断开
13. 安装Windows或Linux系统
14. 服务器对服务器文件传输
15. 安装探针并绑定域名
16. 共用端口（反代）
17. 安装 curl 和 wget
18. 安装 Docker
19. SSH 防暴力破解检测
20. Speedtest测速面板
21. WordPress 安装（基于 Docker）
22. 
请输入选项:

### 快捷启动命令：s
### 探针和v2ray都需要的话要先探针再安装v2ray，不然探针会报错502错误

方法一：直接运行脚本（不保存文件）
```
bash <(curl -sL https://github.com/sinian-liu/onekey/raw/main/onekey.sh)
```
方法二：下载后运行（保存到本地）
```
wget -O /root/onekey.sh https://github.com/sinian-liu/onekey/raw/main/onekey.sh && chmod +x /root/onekey.sh && /root/onekey.sh
```
