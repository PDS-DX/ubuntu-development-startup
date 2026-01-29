#!/usr/bin/env bash
# Install Visual Studio Code via Microsoft APT repo

set -euo pipefail

if is_installed code; then
    log_info "VS Code already installed: $(code --version | head -1)"
    exit 2
fi

log_info "Installing VS Code..."

add_apt_repo_deb822 "vscode" \
    "https://packages.microsoft.com/repos/code" \
    "https://packages.microsoft.com/keys/microsoft.asc" \
    "stable" \
    "main"

apt_install code

log_info "VS Code installed: $(code --version | head -1)"
