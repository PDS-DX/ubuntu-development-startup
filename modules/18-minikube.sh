#!/usr/bin/env bash
# Install minikube via .deb from GitHub releases

set -euo pipefail

if is_installed minikube; then
    log_info "minikube already installed: $(minikube version --short)"
    exit 2
fi

TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' RETURN

DEB_URL="https://github.com/kubernetes/minikube/releases/download/v${MINIKUBE_VERSION}/minikube_${MINIKUBE_VERSION}-0_${ARCH}.deb"

log_info "Downloading minikube v${MINIKUBE_VERSION}..."
curl -fsSL "$DEB_URL" -o "${TMPDIR}/minikube.deb"

log_info "Installing minikube..."
sudo apt-get install -y -qq "${TMPDIR}/minikube.deb"

log_info "minikube installed: $(minikube version --short)"
