#!/usr/bin/env bash
# Install kubectl (APT) and kubectx/kubens (GitHub release)

set -euo pipefail

# --- kubectl ---
if is_installed kubectl && is_installed kubectx; then
    log_info "kubectl already installed"
    exit 2
else
    log_info "Installing kubectl..."
    curl -LO "https://dl.k8s.io/release/v$KUBECTL_VERSION/bin/linux/arm64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm kubectl
    log_info "kubectl installed: $(kubectl version --client --short 2>/dev/null || kubectl version --client)"

    log_info "Installing kubectx..."
    apt_update_if_needed
    sudo apt install kubectx
    log_info "kubectx installed: $(kubectx --version 2>/dev/null)"
fi

log_info "Kubernetes tools setup complete"
