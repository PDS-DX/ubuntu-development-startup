#!/usr/bin/env bash
# Pinned versions, architecture detection, Ubuntu codename helpers

set -euo pipefail

# --- Pinned Versions ---

DOTNET_CHANNEL="10.0"
NODE_VERSION="24"
NVM_VERSION="0.40.1"
KUBECTX_VERSION="0.9.5"
KUBECTL_VERSION="1.31"
JETBRAINS_TOOLBOX_VERSION="2.5.2.35332"
OBSIDIAN_VERSION="1.11.7"
MINIKUBE_VERSION="1.34.0"
PULUMI_VERSION="latest"

export DOTNET_CHANNEL NODE_LTS_VERSION NVM_VERSION
export KUBECTX_VERSION KUBECTL_VERSION
export JETBRAINS_TOOLBOX_VERSION OBSIDIAN_VERSION MINIKUBE_VERSION
export PULUMI_VERSION

# --- Ubuntu Codename Detection ---

detect_codename() {
    UBUNTU_CODENAME="$(lsb_release -cs 2>/dev/null || source /etc/os-release && echo "${UBUNTU_CODENAME:-}")"
    if [[ -z "$UBUNTU_CODENAME" ]]; then
        log_warn "Could not detect Ubuntu codename, defaulting to 'noble'"
        UBUNTU_CODENAME="noble"
    fi
    export UBUNTU_CODENAME
}

# Returns a suite name safe for repos that only support LTS releases
# Falls back to "noble" (24.04 LTS) for non-LTS codenames
lts_suite() {
    local codename="${1:-$UBUNTU_CODENAME}"
    case "$codename" in
        focal|jammy|noble) echo "$codename" ;;
        *)
            log_warn "Non-LTS codename '$codename' detected, falling back to 'noble' for repo suite"
            echo "noble"
            ;;
    esac
}
