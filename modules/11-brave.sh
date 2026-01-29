#!/usr/bin/env bash
# Install Brave browser via APT repo

set -euo pipefail

if is_installed brave-browser; then
    log_info "Brave already installed"
    exit 2
fi

log_info "Installing Brave browser..."

add_apt_repo_deb822 "brave-browser" \
    "https://brave-browser-apt-release.s3.brave.com/" \
    "https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg" \
    "stable" \
    "main"

apt_install brave-browser

log_info "Brave browser installed"
