#!/bin/bash
#
# ddcutil-displaylink.sh
#
# External monitors on the HP USB-C dock are DisplayLink (evdi), not native
# DisplayPort. ddcutil 2.2 can talk DDC/CI to them — the EDID is in sysfs and
# brightness (VCP 0x10) answers on the evdi I2C adapter — but it drops the bus
# first because the platform device has no PCI class 0x030000.
#
# Hidden option --f23 (primitive sysfs) skips that class check. Installed into
# ddcutil's config so `ddcutil` and the GNOME brightness extension pick the
# dock monitors up with no extra flags.
#
# Also ensures the i2c-dev module, the i2c group, and a udev rule. The packaged
# rule only grants access when ATTRS{class}=="0x030000", which these adapters
# never have.
#
# Idempotent. Safe to re-run. Dock does not need to be plugged in.

set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

sudo dnf install -y ddcutil i2c-tools

# ── i2c-dev ──────────────────────────────────────────────────────────────────
if ! lsmod | grep -q '^i2c_dev '; then
    sudo modprobe i2c-dev
fi
if ! grep -Rqx 'i2c-dev' /etc/modules-load.d /usr/lib/modules-load.d 2>/dev/null; then
    echo "i2c-dev" | sudo tee /etc/modules-load.d/i2c-dev.conf >/dev/null
fi

# ── group + udev (group rule, not the PCI-class uaccess rule) ───────────────
getent group i2c >/dev/null || sudo groupadd --system i2c
if ! id -nG "$USER" | tr ' ' '\n' | grep -qx i2c; then
    sudo usermod -aG i2c "$USER"
    echo "Added $USER to group i2c. Log out and back in so it takes effect."
fi

sudo tee /etc/udev/rules.d/60-ddcutil-i2c.rules >/dev/null << 'EOF'
# DisplayLink evdi adapters have no PCI class, so the packaged
# ATTRS{class}=="0x030000" uaccess rule never matches them.
KERNEL=="i2c-[0-9]*", GROUP="i2c", MODE="0660"
EOF
sudo udevadm control --reload-rules
sudo udevadm trigger --subsystem-match=i2c-dev || true

# ── ddcutilrc (--f23). User file wins; system file covers other accounts. ──
install_rc() {
    local dest="$1"
    if [ -f "$dest" ] && grep -q -- '--f23' "$dest"; then
        echo "ddcutilrc already set: $dest"
        return
    fi
    if [ -f "$dest" ]; then
        printf '\n[global]\noptions: --f23\n' >> "$dest"
        echo "Appended --f23 to $dest"
        return
    fi
    mkdir -p "$(dirname "$dest")"
    cp "$DIR/ddcutilrc" "$dest"
    echo "Installed $dest"
}

install_rc "$HOME/.config/ddcutil/ddcutilrc"
sudo mkdir -p /etc/xdg/ddcutil
sudo cp "$DIR/ddcutilrc" /etc/xdg/ddcutil/ddcutilrc

echo ""
echo "ddcutil displays:"
if ddcutil detect --brief; then
    :
else
    echo "ddcutil could not query displays yet. If group i2c was just added, log out and back in."
fi
