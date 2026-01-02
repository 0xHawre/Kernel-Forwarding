cat > ~/add-user.sh << 'EOF'
#!/bin/bash

# Configuration Variables (Ensure these match your setup)
IRAN_IP="94.182.150.72"
BRIDGE_PORT="2096" # The port you used in the IR bridge script
CONFIG_FILE="/usr/local/etc/xray/config.json"

# Colors for nice output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== ⚡ NEW USER GENERATOR (DEEP NETWORK MODE) ===${NC}"

# 1. Ask for a Name
read -p "Enter a name for the new config: " CONFIG_NAME

# Clean name for the link
CLEAN_NAME=$(echo $CONFIG_NAME | sed 's/ /_/g')

# 2. Generate a new random UUID
NEW_UUID=$(cat /proc/sys/kernel/random/uuid)

# 3. Use Python to safely inject the user into the JSON file
# (This avoids messing up the formatting)
python3 - <<PYEND
import json

path = "$CONFIG_FILE"
new_id = "$NEW_UUID"

with open(path, 'r') as f:
    config = json.load(f)

# Find the VLESS inbound
found = False
for inbound in config['inbounds']:
    if inbound['protocol'] == 'vless':
        inbound['settings']['clients'].append({"id": new_id})
        found = True
        break

if not found:
    print("❌ Error: Could not find VLESS inbound in config.")
    exit(1)

with open(path, 'w') as f:
    json.dump(config, f, indent=4)
PYEND

if [ $? -eq 0 ]; then
    # 4. Restart Xray to apply
    systemctl restart xray
    
    # 5. Output the link
    # Pattern matches the "Just-VPN / Less-HTTP" style you liked
    LINK="vless://$NEW_UUID@$IRAN_IP:$BRIDGE_PORT?encryption=none&security=none&type=tcp&headerType=http#$CLEAN_NAME"
    
    echo -e "${GREEN}✅ Config Created Successfully!${NC}"
    echo "--------------------------------------------------------"
    echo -e "${BLUE}Name:${NC} $CONFIG_NAME"
    echo -e "${BLUE}UUID:${NC} $NEW_UUID"
    echo "--------------------------------------------------------"
    echo -e "${GREEN}🔗 YOUR CONNECTION LINK:${NC}"
    echo "$LINK"
    echo "--------------------------------------------------------"
else
    echo "❌ Something went wrong while updating the config."
fi
EOF

chmod +x ~/add-user.shhmod +* ~/add-user.sh
