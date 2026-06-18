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

echo ""
echo "━━━ Setup complete ━━━"
echo ""
echo "Next steps:"
echo "  1. Reboot to activate MOK enrollment (QWERTY keyboard at the prompt + numbers layout)"
echo "  2. Run: source ~/.bashrc"
echo "  3. Log out and back in (or restart GNOME) for the Clipboard Indicator to appear"
