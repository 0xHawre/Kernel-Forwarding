#!/bin/bash

# Bridge Node Setup (Iran) - Hardware Level Speed

read -p "Enter Netherlands (Exit) IP: " NL_IP
LOCAL_PORT=2099
NL_PORT=443

# 1. Enable Kernel IP Forwarding
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
echo "net.core.default_qdisc=fq" | sudo tee -a /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# 2. Reset and Apply NAT Rules (Zero-App Latency)
sudo iptables -t nat -F
sudo iptables -t nat -A PREROUTING -p tcp --dport $LOCAL_PORT -j DNAT --to-destination $NL_IP:$NL_PORT
sudo iptables -t nat -A POSTROUTING -j MASQUERADE

# 3. Prevent Packet Fragmentation (MSS Clamping)
sudo iptables -t mangle -I FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu

# 4. Persistence
sudo apt update && sudo apt install iptables-persistent -y
sudo netfilter-persistent save

echo "✅ Iran Bridge is Active! Forwarding $LOCAL_PORT -> $NL_IP:$NL_PORT"
