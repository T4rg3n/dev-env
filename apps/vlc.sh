#!/bin/bash

# VLC from Flathub. The Fedora Flatpak build has no EAC3 decoder and only
# OpenH264 for H.264; the Flathub build bundles ffmpeg with those codecs.

set -e

if flatpak info org.videolan.vlc &>/dev/null; then
    flatpak uninstall -y org.videolan.vlc
fi

flatpak install -y flathub org.videolan.VLC
