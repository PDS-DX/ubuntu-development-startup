#!/usr/bin/env bash
# Install Visual Studio Code via Microsoft APT repo

set -euo pipefail

if is_installed code; then
    log_info "VS Code already installed: $(code --version | head -1)"
    exit 2
fi

log_info "Installing VS Code..."

sudo apt-get install wget gpg &&
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg &&
sudo install -D -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/microsoft.gpg &&
rm -f microsoft.gpg

sudo tee -a /etc/apt/sources.list.d/vscode.sources > /dev/null <<'EOF'
Types: deb
URIs: https://packages.microsoft.com/repos/code
Suites: stable
Components: main
Architectures: amd64,arm64,armhf
Signed-By: /usr/share/keyrings/microsoft.gpg
EOF

apt update && apt_install code

log_info "VS Code installed: $(code --version | head -1)"
