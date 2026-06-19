#!/bin/bash

# GNOME keyboard shortcuts (idempotent)

# Super + E - open Files (home folder)
gsettings set org.gnome.settings-daemon.plugins.media-keys home "['<Super>e']"

# Super + Shift + S - screenshot snip UI (Windows Snipping Tool equivalent)
gsettings set org.gnome.shell.keybindings show-screenshot-ui "['<Super><Shift>s', 'Print']"

# Super + V - Show clipboard history 
#(already in clipboard.sh)

# Ctrl + Shift + Esc - open btop (uses installed .desktop app) - doesnt work for nowb
#_btop_key='/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/btop/'
#_current_keys=$(gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings)
#if [[ "$_current_keys" != *"$_btop_key"* ]]; then
#  # Strip the "@as " type annotation GVariant adds to empty arrays
#  _current_keys=$(echo "$_current_keys" | sed 's/^@as //')
#  gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings \
#    "$(echo "$_current_keys" | sed "s|]$|, '$_btop_key']|" | sed 's/\[, /[/')"
#fi
#
#btop_binding_path="$_btop_key"
#gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$btop_binding_path" name 'Open btop'
#gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$btop_binding_path" command 'gtk-launch btop'
#gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$btop_binding_path" binding '<Primary><Shift><Escape>'

# Super + D - show desktop (toggle hide all windows)
gsettings set org.gnome.desktop.wm.keybindings show-desktop "['<Super>d']"

# Super + R - open Activities overview (shows search bar, equivalent to 3-finger swipe up)
gsettings set org.gnome.shell.keybindings toggle-overview "['<Super>r']"