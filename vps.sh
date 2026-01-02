#!/bin/bash
# Exit Node Setup (Netherlands)
# Powered by Xray (TCP-HTTP Obfuscation)

 2. Performance Tuning
cat >> /etc/sysctl.conf <<EOF
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
net.ipv4.tcp_fastopen=3
EOF
sysctl -p

# 3. Apply Config
UUID="2fee40fc-8046-4156-9d79-ee8589fd58a8"
PORT=443

cat > /usr/local/etc/xray/config.json <<EOF
{
    "log": { "loglevel": "none" },
    "inbounds": [{
        "port": $PORT, "protocol": "vless",
        "settings": { "clients": [{ "id": "$UUID" }], "decryption": "none" },
        "streamSettings": {
            "network": "tcp",
            "tcpSettings": { "header": { "type": "http", "request": {
                "version": "1.1", "method": "GET", "path": ["/"],
                "headers": { "Host": ["dl.google.com"], "Connection": ["keep-alive"] }
            }}}
        }
    }],
    "outbounds": [{ "protocol": "freedom" }]
}
EOF

systemctl restart xray
echo "✅ Exit Node is Ready on Port $PORT"

