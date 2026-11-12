#!/bin/bash

set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=gnome-extension.sh
source "$DIR/gnome-extension.sh"

UUID="clipboard-indicator@tudmotu.com"
EXT_DIR="$(extension_dir "$UUID")"
GNOME_VERSION="$(gnome_shell_major)"
REPO="https://github.com/Tudmotu/gnome-shell-extension-clipboard-indicator.git"

mkdir -p "$(dirname "$EXT_DIR")"

if [ -z "$GNOME_VERSION" ]; then
    echo "Could not detect GNOME Shell version."
    exit 1
fi

# A leftover checkout from the previous Shell stays "OUT OF DATE" until pulled.
# Upstream master lists the current Shell versions; the extensions.gnome.org
# zip is the same tree.
if [ ! -d "$EXT_DIR/.git" ]; then
    rm -rf "$EXT_DIR"
    git clone "$REPO" "$EXT_DIR"
elif ! extension_supports_shell "$EXT_DIR" "$GNOME_VERSION"; then
    echo "Updating Clipboard Indicator for GNOME $GNOME_VERSION..."
    git -C "$EXT_DIR" pull --ff-only
fi

if ! extension_supports_shell "$EXT_DIR" "$GNOME_VERSION"; then
    echo "Clipboard Indicator still does not list GNOME $GNOME_VERSION."
    exit 1
fi

if [ -d "$EXT_DIR/schemas" ]; then
    glib-compile-schemas "$EXT_DIR/schemas"
fi
fix_extension_perms "$EXT_DIR"

gnome-extensions enable "$UUID"

# Remove the default keybinding
gsettings set org.gnome.shell.keybindings toggle-message-tray "['<Super>m']"

# Clear history at session start (extension load / login / reboot),
# not on a recurring mid-session timer.
SCHEMA_DIR="$EXT_DIR/schemas"
SCHEMA=org.gnome.shell.extensions.clipboard-indicator
if [ -d "$SCHEMA_DIR" ]; then
    gsettings --schemadir "$SCHEMA_DIR" set "$SCHEMA" clear-on-boot true
    gsettings --schemadir "$SCHEMA_DIR" set "$SCHEMA" clear-history-on-interval false
fi
