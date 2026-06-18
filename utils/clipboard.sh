#!/bin/bash

# Check if "~/.local/share/gnome-shell/extensions/" folder exists
if [ ! -d ~/.local/share/gnome-shell/extensions/ ]; then
    mkdir -p ~/.local/share/gnome-shell/extensions/
fi

# Clone the repo into ~
git clone https://github.com/tudmotu/gnome-shell-extension-clipboard-indicator.git ~/.local/share/gnome-shell/extensions/clipboard-indicator@tudmotu.com

# Enable the extension
gnome-extensions enable clipboard-indicator@tudmotu.com

# Remove the default keybinding
gsettings set org.gnome.shell.keybindings toggle-message-tray "['<Super>m']"

