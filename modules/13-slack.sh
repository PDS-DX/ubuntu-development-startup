#!/usr/bin/env bash
# Install Slack — deb package preferred, snap fallback on ARM64

set -euo pipefail

if is_installed slack || is_snap_installed slack; then
    log_info "Slack already installed"
    exit 2
fi

if [[ "$ARCH" == "arm64" ]]; then
    log_warn "Slack .deb is not available for ARM64, falling back to snap"
    sudo snap install slack --classic
    log_info "Slack installed via snap"
    exit 0
fi

TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' RETURN

log_info "Downloading Slack .deb..."
SLACK_URL="https://downloads.slack-edge.com/desktop-releases/linux/x64/4.41.105/slack-desktop-4.41.105-amd64.deb"
curl -fsSL "$SLACK_URL" -o "${TMPDIR}/slack.deb"

log_info "Installing Slack..."
sudo apt-get install -y -qq "${TMPDIR}/slack.deb"

log_info "Slack installed"
