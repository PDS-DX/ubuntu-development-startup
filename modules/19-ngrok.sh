#!/usr/bin/env bash
# Install ngrok via APT repo

set -euo pipefail

if is_installed ngrok; then
    log_info "ngrok already installed: $(ngrok version)"
    exit 2
fi

log_info "Installing ngrok..."

add_apt_repo_deb822 "ngrok" \
    "https://ngrok-agent.s3.amazonaws.com" \
    "https://ngrok-agent.s3.amazonaws.com/ngrok.asc" \
    "stable" \
    "main"

apt_install ngrok

log_info "ngrok installed: $(ngrok version)"
