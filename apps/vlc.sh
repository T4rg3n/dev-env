#!/bin/bash

# VLC from the Fedora Flatpak remote, plus the OpenH264 codec that runtime
# does not ship (needed for H.264 playback).

set -e

FEDORA="$(rpm -E %fedora)"

flatpak install -y fedora "org.fedoraproject.Platform.Codecs.openh264//f${FEDORA}"
flatpak install -y fedora org.videolan.vlc
