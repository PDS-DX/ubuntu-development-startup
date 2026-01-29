#!/usr/bin/env bash
# Install GitHub CLI via APT repo

set -euo pipefail

if is_installed gh; then
    log_info "GitHub CLI already installed: $(gh --version | head -1)"
    exit 2
fi

log_info "Installing GitHub CLI..."

add_apt_repo_deb822 "github-cli" \
    "https://cli.github.com/packages" \
    "https://cli.github.com/packages/githubcli-archive-keyring.gpg" \
    "stable" \
    "main"

apt_install gh

log_info "GitHub CLI installed: $(gh --version | head -1)"
