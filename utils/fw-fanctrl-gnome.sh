#!/bin/bash

set -e

UUID="fw-fanctrl-revived@willow.sh"
EXT_PK=7864

if gnome-extensions list 2>/dev/null | grep -q "$UUID"; then
    echo "Extension $UUID is already installed, ensuring it is enabled..."
    gnome-extensions enable "$UUID"
    exit 0
fi

# Detect current GNOME Shell major version
GNOME_VERSION=$(gnome-shell --version 2>/dev/null | grep -oP '\d+' | head -1)
if [ -z "$GNOME_VERSION" ]; then
    echo "Could not detect GNOME Shell version."
    exit 1
fi
echo "Detected GNOME Shell version: $GNOME_VERSION"

# Resolve the download version_tag from the GNOME extensions API
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

echo "Downloading Framework Fan Control extension (version_tag=${VERSION_TAG})..."
TMPZIP=$(mktemp --suffix=.zip)
trap 'rm -f "$TMPZIP"' EXIT

# The @ in the UUID must be percent-encoded in the URL path
UUID_ENCODED="${UUID/@/%40}"
curl -sSL --fail -o "$TMPZIP" \
    "https://extensions.gnome.org/download-extension/${UUID_ENCODED}.shell-extension.zip?version_tag=${VERSION_TAG}"

gnome-extensions install --force "$TMPZIP"
gnome-extensions enable "$UUID"

echo "Extension '$UUID' installed and enabled."
echo "Log out and back in (or restart GNOME Shell) for the quick-settings toggle to appear."
