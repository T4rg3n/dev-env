#!/bin/bash

# Install every Flatpak app listed in flatpak-packages.txt (app id, then remote).

set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

flatpak remote-add --if-not-exists --system flathub https://dl.flathub.org/repo/flathub.flatpakrepo

while read -r app origin; do
    [ -z "$app" ] && continue
    flatpak install -y --system "$origin" "$app"
done < "$DIR/flatpak-packages.txt"
