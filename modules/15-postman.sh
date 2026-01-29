#!/usr/bin/env bash
# Install Postman via snap

set -euo pipefail

if is_snap_installed postman; then
    log_info "Postman already installed"
    exit 2
fi

if [[ "$ARCH" == "arm64" ]]; then
    log_warn "Postman does not officially support ARM64 — skipping"
    exit 2
fi

log_info "Installing Postman via snap..."
sudo snap install postman

log_info "Postman installed"
