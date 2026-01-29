#!/usr/bin/env bash
# Install JetBrains Toolbox via tarball download

set -euo pipefail

INSTALL_DIR="${HOME}/.local/share/JetBrains/Toolbox"
TOOLBOX_BIN="${INSTALL_DIR}/bin/jetbrains-toolbox"

if [[ -x "$TOOLBOX_BIN" ]]; then
    log_info "JetBrains Toolbox already installed"
    exit 2
fi

# Map architecture for JetBrains download URL
case "$UNAME_ARCH" in
    x86_64)  JB_ARCH="x64" ;;
    aarch64) JB_ARCH="aarch64" ;;
    *)       log_error "Unsupported arch for JetBrains Toolbox: $UNAME_ARCH"; exit 1 ;;
esac

TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' RETURN

URL="https://download.jetbrains.com/toolbox/jetbrains-toolbox-${JETBRAINS_TOOLBOX_VERSION}-linux-${JB_ARCH}.tar.gz"

log_info "Downloading JetBrains Toolbox v${JETBRAINS_TOOLBOX_VERSION}..."
curl -fsSL "$URL" -o "${TMPDIR}/toolbox.tar.gz"

log_info "Extracting to ${INSTALL_DIR}..."
mkdir -p "$INSTALL_DIR/bin"
tar xzf "${TMPDIR}/toolbox.tar.gz" -C "$TMPDIR"
cp "${TMPDIR}"/jetbrains-toolbox-*/jetbrains-toolbox "${TOOLBOX_BIN}"
chmod +x "$TOOLBOX_BIN"

log_info "JetBrains Toolbox installed to ${TOOLBOX_BIN}"
log_info "Run 'jetbrains-toolbox' to launch (after adding ~/.local/share/JetBrains/Toolbox/bin to PATH)"
