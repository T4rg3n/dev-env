#!/bin/bash

set -e

# The binary surviving a Fedora upgrade is not enough: it is a Python package
# installed into the previous interpreter's site-packages. F45 moved
# /usr/bin/python3 to 3.15 and left fw_fanctrl on 3.14, so the service
# crash-loops with ModuleNotFoundError.
if command -v fw-fanctrl &>/dev/null && python3 -c 'import fw_fanctrl' &>/dev/null; then
    echo "fw-fanctrl is already installed: $(fw-fanctrl --version 2>/dev/null || echo 'version unknown')"
    exit 0
fi

if command -v fw-fanctrl &>/dev/null; then
    echo "fw-fanctrl is installed but $(python3 --version) cannot import it. Reinstalling."
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
