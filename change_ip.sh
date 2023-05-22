#!/bin/bash

# 配置新的 IP 地址和子网掩码
NEW_IP="172.16.X.X"
NETMASK_CIDR="16"

# 配置默认网关和 DNS 服务器
GATEWAY="172.16.X.X"
DNS_SERVERS="172.16.X.X"

# 获取当前网络接口名称
INTERFACE=$(ip -o -4 route show to default | awk '{print $5}')

# 生成新的 Netplan 配置文件内容
CONFIG_CONTENT="network:
  version: 2
  ethernets:
    $INTERFACE:
      addresses: ["$NEW_IP/$NETMASK_CIDR"]
      gateway4: $GATEWAY
      nameservers:
        addresses: [$DNS_SERVERS]"

# 创建临时配置文件
TMP_CONFIG="/tmp/netplan-config.yaml"
echo "$CONFIG_CONTENT" | sudo tee "$TMP_CONFIG" > /dev/null

# 应用新的网络配置
sudo cp "$TMP_CONFIG" "/etc/netplan/00-installer-config.yaml"
sudo netplan apply

# 删除临时配置文件
rm "$TMP_CONFIG"

# 输出当前网络配置信息
ip a
