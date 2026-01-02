#!/bin/bash
# DEEP-LAYER ENDPOINT (NL)
# Gost V3 - Custom Relay Obfuscator

# 1. Download Gost (The Engine)
wget https://github.com/go-gost/gost/releases/download/v3.0.0-rc.10/gost_3.0.0-rc.10_linux_amd64.tar.gz
tar -xvf gost_*.tar.gz && mv gost /usr/bin/

# 2. Optimized Kernel Config (Layer 4 Tweaks)
cat >> /etc/sysctl.conf <<EOF
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_slow_start_after_idle = 0
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr
net.ipv4.tcp_notsent_lowat = 16384
EOF
sysctl -p

# 3. Start Stealth Service (Hiding as an encrypted data stream)
# PORT 443 with Relay+mTLS encryption
# replace 'mypassword' with a secret string
cat > /etc/systemd/system/gost-endpoint.service <<EOF
[Unit]
Description=Gost Deep Stealth
After=network.target

[Service]
ExecStart=/usr/bin/gost -L relay+tls://:443?password=mypassword&cert=/etc/xray/self.crt&key=/etc/xray/self.key
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now gost-endpoint
echo "Deep-Level Exit Active"
