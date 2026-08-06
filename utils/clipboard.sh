#!/bin/bash

# Check if "~/.local/share/gnome-shell/extensions/" folder exists
if [ ! -d ~/.local/share/gnome-shell/extensions/ ]; then
    mkdir -p ~/.local/share/gnome-shell/extensions/
fi

EXT_DIR=~/.local/share/gnome-shell/extensions/clipboard-indicator@tudmotu.com

# Clone the repo if missing
if [ ! -d "$EXT_DIR" ]; then
    git clone https://github.com/tudmotu/gnome-shell-extension-clipboard-indicator.git "$EXT_DIR"
fi

# Enable the extension
gnome-extensions enable clipboard-indicator@tudmotu.com

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
