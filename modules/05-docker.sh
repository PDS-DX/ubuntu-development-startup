#!/usr/bin/env bash
# Install Docker Engine + Compose plugin

set -euo pipefail

if is_installed docker; then
    log_info "Docker already installed: $(docker --version)"
    # Ensure user is in docker group
    if ! groups "$USER" | grep -qw docker; then
        log_info "Adding $USER to docker group..."
        sudo usermod -aG docker "$USER"
    fi
    exit 2
fi

SUITE="$(lts_suite)"

add_apt_repo_deb822 "docker" \
    "https://download.docker.com/linux/ubuntu" \
    "https://download.docker.com/linux/ubuntu/gpg" \
    "$SUITE" \
    "stable"

apt_install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add user to docker group
sudo usermod -aG docker "$USER"
log_warn "Added $USER to docker group — log out and back in for this to take effect"

log_info "Docker installed: $(docker --version)"
