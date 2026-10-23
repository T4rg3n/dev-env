#!/bin/bash

set -e

# ── External repos ────────────────────────────────────────────────────────────

# GitHub CLI
if [ ! -f /etc/yum.repos.d/gh-cli.repo ]; then
    sudo dnf config-manager addrepo --from-repofile=https://cli.github.com/packages/rpm/gh-cli.repo
fi

# VS Code
if [ ! -f /etc/yum.repos.d/vscode.repo ]; then
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" \
        | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null
fi

# Tailscale — Fedora's package lags far behind upstream; use Tailscale's repo
# so `dnf update` actually gets current releases (e.g. 1.104+ vs Fedora's 1.98).
if [ ! -f /etc/yum.repos.d/tailscale.repo ]; then
    sudo dnf config-manager addrepo --from-repofile=https://pkgs.tailscale.com/stable/fedora/tailscale.repo
fi

# ── Packages ──────────────────────────────────────────────────────────────────

sudo dnf install -y \
    btop \
    fprintd \
    fprintd-pam \
    akmod-evdi \
    gh \
    code \
    tlp \
    tlp-rdw \
    powertop \
    tuned \
    docker-cli \
    docker-compose-switch \
    ddcutil \
    i2c-tools \
    tailscale

# Upgrade Tailscale if Fedora's older package was already installed before the
# official repo was added (plain `dnf install` alone may leave the old version).
sudo dnf update -y tailscale

# Allow current user to run docker without sudo (re-login required)
sudo usermod -aG docker "$USER"

echo "All packages installed."
