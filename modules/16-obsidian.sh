#!/usr/bin/env bash
# Install Obsidian via .deb from GitHub releases

set -euo pipefail

if is_flatpak_installed Obsidian; then
    log_info "Obsidian already installed"
    exit 2
fi

TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' RETURN

log_info "Installing Obsidian..."
flatpak install flathub md.obsidian.Obsidian

log_info "Obsidian installed"
