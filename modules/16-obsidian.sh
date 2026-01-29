#!/usr/bin/env bash
# Install Obsidian via .deb from GitHub releases

set -euo pipefail

if is_installed obsidian || is_apt_installed obsidian; then
    log_info "Obsidian already installed"
    exit 2
fi

TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' RETURN

# Obsidian .deb naming uses amd64/arm64
DEB_URL="https://github.com/obsidianmd/obsidian-releases/releases/download/v${OBSIDIAN_VERSION}/obsidian_${OBSIDIAN_VERSION}_${ARCH}.deb"

log_info "Downloading Obsidian v${OBSIDIAN_VERSION}..."
curl -fsSL "$DEB_URL" -o "${TMPDIR}/obsidian.deb"

log_info "Installing Obsidian..."
sudo apt-get install -y -qq "${TMPDIR}/obsidian.deb"

log_info "Obsidian installed"
