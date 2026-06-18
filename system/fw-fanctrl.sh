#!/bin/bash

set -e

if command -v fw-fanctrl &>/dev/null; then
    echo "fw-fanctrl is already installed: $(fw-fanctrl --version 2>/dev/null || echo 'version unknown')"
    exit 0
fi

echo "Installing fw-fanctrl dependencies..."
sudo dnf install -y python3-build python3-pip

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

echo "Cloning fw-fanctrl..."
git clone --depth=1 https://github.com/TamtamHero/fw-fanctrl.git "$TMPDIR/fw-fanctrl"

echo "Running fw-fanctrl installer..."
cd "$TMPDIR/fw-fanctrl"
sudo ./install.sh

echo "fw-fanctrl installed and service enabled."
echo "Check status with: systemctl status fw-fanctrl"
echo "Switch strategy with: fw-fanctrl use <strategy>"
