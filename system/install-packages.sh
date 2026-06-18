#!/bin/bash

set -e

# ── External repos ────────────────────────────────────────────────────────────

# GitHub CLI
if ! dnf repolist | grep -q "gh-cli"; then
    sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
fi

# VS Code
if [ ! -f /etc/yum.repos.d/vscode.repo ]; then
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" \
        | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null
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
    tuned

echo "All packages installed."
