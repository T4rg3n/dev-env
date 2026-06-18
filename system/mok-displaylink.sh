#!/bin/bash

set -e

MOK_KEY="/var/lib/dkms/mok.pub"

# akmod-evdi must be installed first (handled by install-packages.sh)
if ! rpm -q akmod-evdi &>/dev/null; then
    echo "akmod-evdi is not installed. Run install-packages.sh first."
    exit 1
fi

if [ ! -f "$MOK_KEY" ]; then
    echo "MOK key not found at $MOK_KEY"
    echo "The DKMS module may not have built yet. Try: sudo akmods --force"
    exit 1
fi

sudo mokutil --import "$MOK_KEY"

echo ""
echo "MOK key enrollment requested. Reboot to complete enrollment."
echo "IMPORTANT: The MOK Manager screen uses QWERTY keyboard layout."
