#!/bin/bash
# KERNEL-LEVEL FORWARDER (IRAN)

read -p "Enter NL IP Address: " NL_IP
SECRET="mypassword"

# 1. Clean previous Firewall layers
iptables -t nat -F
iptables -t mangle -F

# 2. Install GOST Engine for local translation
wget https://github.com/go-gost/gost/releases/download/v3.0.0-rc.10/gost_3.0.0-rc.10_linux_amd64.tar.gz
tar -xvf gost_*.tar.gz && mv gost /usr/bin/

# 3. Create the Tunnel Pipe (Local to NL)
# This binds your server to a secure relay pipe
cat > /etc/systemd/system/bridge-deep.service <<EOF
[Unit]
Description=Gost Local Tunnel
After=network.target

[Service]
ExecStart=/usr/bin/gost -L tcp://:2099 -F relay+tls://${NL_IP}:443?password=${SECRET}
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# 4. KERNEL MANGLE: The Magic Trick
# This optimizes packet size so the ISP cannot detect MTU patterns
iptables -t mangle -A POSTROUTING -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu

systemctl daemon-reload
systemctl enable --now bridge-deep
echo "Bridge Active on Port 2099"
