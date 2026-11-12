#!/bin/bash
#
# French AZERTY for the session and for the lock screen.
#
# The user session reads org.gnome.desktop.input-sources. GDM and the lock
# screen follow the system keymap from localectl. A Fedora upgrade resets
# that to us, so the password field comes up QWERTY while the session stays
# on fr+azerty.

set -e

gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'fr+azerty')]"

x11_layout="$(localectl status | awk -F: '/X11 Layout/ { gsub(/ /,"",$2); print $2 }')"
x11_variant="$(localectl status | awk -F: '/X11 Variant/ { gsub(/ /,"",$2); print $2 }')"
vc_keymap="$(localectl status | awk -F: '/VC Keymap/ { gsub(/ /,"",$2); print $2 }')"

if [ "$x11_layout" = "fr" ] && [ "$x11_variant" = "azerty" ] && [ "$vc_keymap" = "fr-azerty" ]; then
    echo "System keymap is already French (AZERTY)."
    exit 0
fi

# set-x11-keymap also converts the layout into a console keymap.
sudo localectl set-x11-keymap fr pc105 azerty
sudo localectl set-keymap fr-azerty

echo "System keymap set to French (AZERTY). Log out so the lock screen picks it up."
