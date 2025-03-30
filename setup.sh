#!/bin/bash

# Destination directory on Synology
DEST_DIR="/volume1/scripts/autovpn"

# Git repository URL
REPO_URL="https://github.com/byipr/autovpn.git"

# Check if running from within the repo
if [ -d "$DEST_DIR/.git" ]; then
    echo "Already in a Git repo, updating..."
    cd "$DEST_DIR" && git pull
else
    # Check if git is installed
    if ! command -v git &> /dev/null; then
        echo "Git is not installed. Please install Git or manually download the repo."
        exit 1
    fi

    # Clone the repository
    echo "Cloning repository..."
    git clone "$REPO_URL" "$DEST_DIR"
fi
SCRIPT_DIR="$DEST_DIR"

# Extract conf_id, conf_name, and proto with sudo
CONF_ID=$(sudo grep "conf_id" /usr/syno/etc/synovpnclient/vpnc_last_connect | cut -d'=' -f2)
CONF_NAME=$(sudo grep "conf_name" /usr/syno/etc/synovpnclient/vpnc_last_connect | cut -d'=' -f2)
PROTO=$(sudo grep "proto" /usr/syno/etc/synovpnclient/vpnc_last_connect | cut -d'=' -f2)

# Check if conf_id is empty (required field)
if [ -z "$CONF_ID" ]; then
    echo "Error: Could not retrieve conf_id. Please connect the VPN manually first via DSM GUI."
    exit 1
fi

# Populate conf_id, conf_name, and proto into vpn_connect.sh and conf_id into vpn_disconnect.sh using sed
sudo sed -i "s/<CONF_ID>/$CONF_ID/g" "$SCRIPT_DIR/vpn_connect.sh"
sudo sed -i "s/<CONF_NAME>/$CONF_NAME/g" "$SCRIPT_DIR/vpn_connect.sh"
sudo sed -i "s/<PROTO>/$PROTO/g" "$SCRIPT_DIR/vpn_connect.sh"
sudo sed -i "s/<CONF_ID>/$CONF_ID/g" "$SCRIPT_DIR/vpn_disconnect.sh"

# Make scripts executable
chmod +x "$SCRIPT_DIR/vpn_connect.sh"
chmod +x "$SCRIPT_DIR/vpn_disconnect.sh"

echo "Setup complete. Configured with conf_id=$CONF_ID, conf_name=$CONF_NAME, proto=$PROTO"
echo "Configure Task Scheduler with $SCRIPT_DIR/vpn_connect.sh and $SCRIPT_DIR/vpn_disconnect.sh"