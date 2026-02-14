#!/usr/bin/env bash
# Install Ferdium

set -euo pipefail

if is_flatpak_installed Ferdium; then
    log_info "Ferdium already installed"
    exit 2
fi

if [[ "$ARCH" == "arm64" ]]; then
    flatpak install flathub org.ferdium.Ferdium
    log_info "Ferdium installed via flatpak"
    exit 0
fi

log_info "Ferdium installed"
