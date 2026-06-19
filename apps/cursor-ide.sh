#!/bin/bash

# Cursor IDE through DNF (instead of AppImage & Gearlevel)

echo "Adding Cursor IDE repository..."
sudo tee /etc/yum.repos.d/cursor.repo >/dev/null <<'EOF'
[cursor]
name=Cursor
baseurl=https://downloads.cursor.com/yumrepo
enabled=1
gpgcheck=1
gpgkey=https://downloads.cursor.com/keys/anysphere.asc
repo_gpgcheck=1
EOF

sudo dnf install cursor