#!/usr/bin/env bash
# Shared functions: logging, idempotency checks, apt helpers

set -euo pipefail

# --- Logging ---

LOG_FILE="/tmp/dev-setup-$(date +%Y%m%d-%H%M%S).log"
readonly RED='\033[0;31m'
readonly YELLOW='\033[1;33m'
readonly GREEN='\033[0;32m'
readonly BLUE='\033[1;34m'
readonly BOLD='\033[1m'
readonly RESET='\033[0m'

_log() {
    local color="$1" label="$2"
    shift 2
    local msg="$*"
    local ts
    ts="$(date +%H:%M:%S)"
    printf "${color}[%s %s]${RESET} %s\n" "$ts" "$label" "$msg" | tee -a "$LOG_FILE"
}

log_info()    { _log "$GREEN"  "INFO"    "$@"; }
log_warn()    { _log "$YELLOW" "WARN"    "$@"; }
log_error()   { _log "$RED"    "ERROR"   "$@"; }
log_section() { printf "\n${BLUE}${BOLD}══════ %s ══════${RESET}\n\n" "$*" | tee -a "$LOG_FILE"; }

# --- Sudo ---

ensure_sudo() {
    if ! sudo -n true 2>/dev/null; then
        log_info "Requesting sudo access..."
        sudo -v
    fi
    # Keep sudo alive in the background
    while true; do
        sudo -n true 2>/dev/null
        sleep 50
    done &
    SUDO_KEEPALIVE_PID=$!
    trap 'kill $SUDO_KEEPALIVE_PID 2>/dev/null || true' EXIT
}

# --- Architecture ---

detect_arch() {
    UNAME_ARCH="$(uname -m)"
    case "$UNAME_ARCH" in
        x86_64)  ARCH="amd64" ;;
        aarch64) ARCH="arm64" ;;
        *)       log_error "Unsupported architecture: $UNAME_ARCH"; exit 1 ;;
    esac
    export ARCH UNAME_ARCH
}

# --- Idempotency helpers ---

is_installed() {
    command -v "$1" &>/dev/null
}

is_apt_installed() {
    dpkg -l "$1" 2>/dev/null | grep -q "^ii"
}

is_snap_installed() {
    snap list "$1" 2>/dev/null | grep -q "^$1"
}

is_flatpak_installed() {
    flatpak list --columns=name 2>/dev/null | grep -q "$1"
}

# --- APT helpers ---

apt_update_if_needed() {
    local last_update
    last_update="$(stat -c %Y /var/lib/apt/lists/partial 2>/dev/null || echo 0)"
    local now
    now="$(date +%s)"
    local age=$(( now - last_update ))
    # Update if lists are older than 1 hour
    if (( age > 3600 )); then
        log_info "Updating APT package lists..."
        sudo apt-get update -qq
    fi
}

# --- DEB822 APT repo helper ---
# Adds an APT repo using modern .sources format with GPG key in /usr/share/keyrings/
#
# Usage: add_apt_repo_deb822 <name> <url> <key_url> <suites> <components> [arch]
#   name       - base name for files (e.g. "docker")
#   url        - repo URL (e.g. "https://download.docker.com/linux/ubuntu")
#   key_url    - URL to GPG key
#   suites     - distribution suite (e.g. "noble")
#   components - repo components (e.g. "stable")
#   arch       - optional architecture filter (defaults to $ARCH)

add_apt_repo_deb822() {
    local name="$1"
    local url="$2"
    local key_url="$3"
    local suites="$4"
    local components="$5"
    local arch="${6:-$ARCH}"

    local sources_file="/etc/apt/sources.list.d/${name}.sources"
    local keyring_file="/usr/share/keyrings/${name}-archive-keyring.gpg"

    if [[ -f "$sources_file" ]]; then
        log_info "APT repo '${name}' already configured, skipping"
        return 0
    fi

    log_info "Adding APT repo: ${name}"

    # Download and dearmor GPG key
    curl -fsSL "$key_url" | sudo gpg --dearmor -o "$keyring_file"

    # Write DEB822 format sources file
    sudo tee "$sources_file" > /dev/null <<EOF
Types: deb
URIs: ${url}
Suites: ${suites}
Components: ${components}
Architectures: ${arch}
Signed-By: ${keyring_file}
EOF

    sudo apt-get update -qq
}
