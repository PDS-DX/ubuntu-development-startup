#!/usr/bin/env bash
# Install kubectl (APT) and kubectx/kubens (GitHub release)

set -euo pipefail

# --- kubectl ---
if is_installed kubectl; then
    log_info "kubectl already installed"
else
    log_info "Installing kubectl..."
    add_apt_repo_deb822 "kubernetes" \
        "https://pkgs.k8s.io/core:/stable:/v${KUBECTL_VERSION}/deb/" \
        "https://pkgs.k8s.io/core:/stable:/v${KUBECTL_VERSION}/deb/Release.key" \
        "/" \
        ""

    apt_install kubectl
    log_info "kubectl installed: $(kubectl version --client --short 2>/dev/null || kubectl version --client)"
fi

# --- kubectx / kubens ---
if is_installed kubectx && is_installed kubens; then
    log_info "kubectx/kubens already installed"
else
    log_info "Installing kubectx/kubens v${KUBECTX_VERSION}..."
    local_bin="${HOME}/.local/bin"
    mkdir -p "$local_bin"

    for tool in kubectx kubens; do
        local url="https://github.com/ahmetb/kubectx/releases/download/v${KUBECTX_VERSION}/${tool}_v${KUBECTX_VERSION}_linux_${UNAME_ARCH}.tar.gz"
        curl -fsSL "$url" | tar xz -C "$local_bin" "$tool"
        chmod +x "${local_bin}/${tool}"
        log_info "Installed ${tool} to ${local_bin}/${tool}"
    done
fi

log_info "Kubernetes tools setup complete"
