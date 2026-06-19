#!/bin/bash

# Master setup script — run this to restore the full environment from scratch.
# Each sub-script is idempotent and safe to re-run.

set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

step() { echo ""; echo "━━━ $1 ━━━"; }

step "Installing DNF packages + external repos"
bash "$DIR/system/install-packages.sh"

step "Configuring deep sleep (mem_sleep_default=deep)"
bash "$DIR/system/powerconfig.sh"

step "Enabling tuned + balanced-battery profile"
bash "$DIR/system/battery-profile.sh"

step "NVMe/WiFi runtime autosuspend udev rules"
bash "$DIR/system/suspend-nvme-wifi.sh"

step "MOK key enrollment for DisplayLink (akmod-evdi)"
bash "$DIR/system/mok-displaylink.sh"

step "Disabling GNOME fundraiser notifications"
bash "$DIR/system/fundraiser-notifications.sh"

step "Installing Clipboard Indicator GNOME extension"
bash "$DIR/utils/clipboard.sh"

step "Installing Gear Lever (AppImage manager)"
bash "$DIR/utils/gearlevel.sh"

step "Configuring shell aliases"
bash "$DIR/utils/aliases.sh"

step "Configuring GNOME keyboard shortcuts"
bash "$DIR/utils/keybindings.sh"

step "Removing Fedora's firefox homepage"
sudo dnf remove fedora-bookmarks 
sudo rm -f /usr/lib64/firefox//browser/defaults/preferences/firefox-redhat-default-prefs.js # the thing that sets the homepage to fedora.org

step "Installing uv (Python toolchain manager)"
bash "$DIR/utils/uv.sh"

step "Installing Python 3.14 via uv"
bash "$DIR/utils/python314.sh"

step "Installing fw-fanctrl (Framework fan control service)"
bash "$DIR/system/fw-fanctrl.sh"

step "Installing Framework Fan Control GNOME extension"
bash "$DIR/utils/fw-fanctrl-gnome.sh"

step "Configuring intel_lpmd (Low Power Mode)"
bash "$DIR/system/lpmd.sh"

echo ""
echo "━━━ Setup complete ━━━"
echo ""
echo "Next steps:"
echo "  1. Reboot to activate MOK enrollment (QWERTY keyboard at the prompt + numbers layout)"
echo "  2. Run: source ~/.bashrc"
echo "  3. Log out and back in (or restart GNOME) for the Clipboard Indicator and fan control extension to appear"
