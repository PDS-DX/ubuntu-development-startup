#!/usr/bin/env bash
# Install Pulumi via official install script

set -euo pipefail

if is_installed pulumi; then
    log_info "Pulumi already installed: $(pulumi version)"
    exit 2
fi

log_info "Installing Pulumi..."
curl -fsSL https://get.pulumi.com | sh

log_info "Pulumi installed: $(~/.pulumi/bin/pulumi version)"
