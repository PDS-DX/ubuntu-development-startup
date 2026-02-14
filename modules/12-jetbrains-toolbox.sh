#!/usr/bin/env bash
# Install JetBrains Toolbox via tarball download

set -euo pipefail

INSTALL_DIR="${HOME}/.local/share/JetBrains/Toolbox"
TOOLBOX_BIN="${INSTALL_DIR}"

if [[ -x "$TOOLBOX_BIN" ]]; then
    log_info "JetBrains Toolbox already installed at $TOOLBOX_BIN"
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

URL="https://download.jetbrains.com/toolbox/jetbrains-toolbox-3.2.0.65851-arm64.tar.gz"

log_info "Downloading JetBrains Toolbox v${JETBRAINS_TOOLBOX_VERSION}..."
curl -fsSL "$URL" -o "${TMPDIR}/toolbox.tar.gz"

log_info "Extracting to ${INSTALL_DIR}..."
mkdir -p "$INSTALL_DIR/bin"
echo "Temporary dir: ${TMPDIR}"
ls -la "${TMPDIR}"
tar -xzf "${TMPDIR}/toolbox.tar.gz" -C "$TMPDIR"
cp -r "${TMPDIR}"/jetbrains-toolbox-*/bin/ "${TOOLBOX_BIN}"
chmod +x "$TOOLBOX_BIN"

echo 'export PATH=$PATH:$HOME/.local/share/JetBrains/Toolbox/bin' >> ~/.bashrc
source ~/.bashrc

log_info "JetBrains Toolbox installed to ${TOOLBOX_BIN}"
log_info "Run 'jetbrains-toolbox' to launch. This will create the desktop symlink."
