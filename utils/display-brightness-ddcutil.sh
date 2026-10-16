#!/bin/bash

set -e

UUID="display-brightness-ddcutil@themightydeity.github.com"
EXT_PK=2645
EXT_DIR="${HOME}/.local/share/gnome-shell/extensions/${UUID}"

# gnome-extensions install leaves metadata.json mode 600, which makes the
# running shell treat the extension as missing until the mode is relaxed.
fix_perms() {
    if [ -d "$EXT_DIR" ]; then
        chmod -R u+rwX,go+rX "$EXT_DIR"
    fi
}

if gnome-extensions list 2>/dev/null | grep -q "$UUID"; then
    echo "Extension $UUID is already installed, ensuring it is enabled..."
    fix_perms
    gnome-extensions enable "$UUID"
    exit 0
fi

GNOME_VERSION=$(gnome-shell --version 2>/dev/null | grep -oP '\d+' | head -1)
if [ -z "$GNOME_VERSION" ]; then
    echo "Could not detect GNOME Shell version."
    exit 1
fi
echo "Detected GNOME Shell version: $GNOME_VERSION"

VERSION_TAG=$(curl -sf "https://extensions.gnome.org/extension-info/?pk=${EXT_PK}&shell_version=${GNOME_VERSION}" \
    | python3 -c "
import sys, json
data = json.load(sys.stdin)
vm = data.get('shell_version_map', {})
key = '${GNOME_VERSION}'
if key in vm:
    print(vm[key]['pk'])
else:
    sys.exit(1)
" 2>/dev/null) || true

if [ -z "$VERSION_TAG" ]; then
    echo "No extension release found for GNOME Shell $GNOME_VERSION."
    echo "Install manually from: https://extensions.gnome.org/extension/${EXT_PK}/"
    exit 1
fi

echo "Downloading Brightness control using ddcutil (version_tag=${VERSION_TAG})..."
TMPZIP=$(mktemp --suffix=.zip)
trap 'rm -f "$TMPZIP"' EXIT

UUID_ENCODED="${UUID/@/%40}"
curl -sSL --fail -o "$TMPZIP" \
    "https://extensions.gnome.org/download-extension/${UUID_ENCODED}.shell-extension.zip?version_tag=${VERSION_TAG}"

gnome-extensions install --force "$TMPZIP"
fix_perms
gnome-extensions enable "$UUID"

echo "Extension '$UUID' installed and enabled."
echo "Log out and back in (or restart GNOME Shell) for the brightness sliders to appear."
