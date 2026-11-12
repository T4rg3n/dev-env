#!/bin/bash

set -e

MOK_KEY="/var/lib/dkms/mok.pub"

# Fedora does not ship akmod-evdi. The DisplayLink RPM installs evdi under
# /usr/src and DKMS signs it with this key. akmod-evdi is accepted too, for
# machines that still have it from an older repo.
if ! rpm -q displaylink &>/dev/null && ! rpm -q akmod-evdi &>/dev/null; then
    echo "Neither displaylink nor akmod-evdi is installed."
    echo "Install the DisplayLink RPM (it bundles evdi), then re-run this script."
    exit 1
fi

if [ ! -f "$MOK_KEY" ]; then
    echo "MOK key not found at $MOK_KEY"
    echo "The DKMS module may not have built yet. Try: sudo dkms autoinstall"
    exit 1
fi

if sudo mokutil --test-key "$MOK_KEY" &>/dev/null; then
    echo "MOK key already enrolled."
    exit 0
fi

sudo mokutil --import "$MOK_KEY"

echo ""
echo "MOK key enrollment requested. Reboot to complete enrollment."
echo "IMPORTANT: The MOK Manager screen uses QWERTY keyboard layout."
