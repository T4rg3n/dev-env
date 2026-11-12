#!/bin/bash

set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=gnome-extension.sh
source "$DIR/gnome-extension.sh"

UUID="fw-fanctrl-revived@willow.sh"
EXT_PK=7864
EXT_DIR="$(extension_dir "$UUID")"

# Detect current GNOME Shell major version
GNOME_VERSION="$(gnome_shell_major)"
if [ -z "$GNOME_VERSION" ]; then
    echo "Could not detect GNOME Shell version."
    exit 1
fi
echo "Detected GNOME Shell version: $GNOME_VERSION"

# "Already installed" is not enough after a Shell upgrade: GNOME hides the
# extension when metadata.json does not list the running major.
if extension_supports_shell "$EXT_DIR" "$GNOME_VERSION"; then
    echo "Extension $UUID already supports GNOME $GNOME_VERSION, ensuring it is enabled..."
    fix_extension_perms "$EXT_DIR"
    gnome-extensions enable "$UUID"
    exit 0
fi

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
fix_extension_perms "$EXT_DIR"
gnome-extensions enable "$UUID"

echo "Extension '$UUID' installed and enabled."
echo "Log out and back in (or restart GNOME Shell) for the quick-settings toggle to appear."
