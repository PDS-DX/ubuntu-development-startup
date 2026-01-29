#!/usr/bin/env bash
# Install AWS CLI v2 via official zip installer

set -euo pipefail

if is_installed aws; then
    log_info "AWS CLI already installed: $(aws --version)"
    # Run with --update to ensure latest
    log_info "Checking for AWS CLI updates..."
    TMPDIR="$(mktemp -d)"
    trap 'rm -rf "$TMPDIR"' RETURN

    curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-${UNAME_ARCH}.zip" -o "${TMPDIR}/awscliv2.zip"
    unzip -q "${TMPDIR}/awscliv2.zip" -d "$TMPDIR"
    sudo "${TMPDIR}/aws/install" --update
    log_info "AWS CLI updated: $(aws --version)"
    exit 2
fi

TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' RETURN

log_info "Installing AWS CLI v2..."
curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-${UNAME_ARCH}.zip" -o "${TMPDIR}/awscliv2.zip"
unzip -q "${TMPDIR}/awscliv2.zip" -d "$TMPDIR"
sudo "${TMPDIR}/aws/install"

log_info "AWS CLI installed: $(aws --version)"
