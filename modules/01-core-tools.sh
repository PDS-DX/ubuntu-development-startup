#!/usr/bin/env bash
# Install core CLI tools via apt

set -euo pipefail

PACKAGES=(
    git
    curl
    wget
    jq
    htop
    vim
    tree
    unzip
    build-essential
    ripgrep
    fd-find
    bat
    fzf
    tmux
    httpie
    xclip
    net-tools
    software-properties-common
    apt-transport-https
    ca-certificates
    gnupg
    lsb-release
    flatpak
    libfuse2t64
)

# Check which packages are missing
MISSING=()
for pkg in "${PACKAGES[@]}"; do
    if ! is_apt_installed "$pkg"; then
        MISSING+=("$pkg")
    fi
done

if [[ ${#MISSING[@]} -eq 0 ]]; then
    log_info "All core tools already installed"
    exit 2
fi

log_info "Installing ${#MISSING[@]} core packages: ${MISSING[*]}"
apt_update_if_needed
apt_install "${MISSING[@]}"

log_info "Core tools installed successfully"
