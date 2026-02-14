#!/usr/bin/env bash
# Install Postman via tar.gz for arm64 Linux

set -euo pipefail

POSTMAN_URL="https://dl.pstmn.io/download/latest/linux_arm64"
INSTALL_DIR="/opt/Postman"
DESKTOP_FILE="/usr/share/applications/postman.desktop"
SYMLINK="/usr/local/bin/postman"
TMP_DIR="$(mktemp -d)"

cleanup() {
    rm -rf "$TMP_DIR"
}
trap cleanup EXIT

# Check if already installed
if [ -x "$INSTALL_DIR/app/Postman" ]; then
    log_info "Postman already installed at $INSTALL_DIR"
    exit 2
fi

log_info "Downloading Postman for arm64..."
curl -fSL "$POSTMAN_URL" -o "$TMP_DIR/postman.tar.gz"

log_info "Extracting Postman..."
tar -xzf "$TMP_DIR/postman.tar.gz" -C "$TMP_DIR"

# The tarball extracts to a directory containing a "Postman" folder
# Find it regardless of the outer directory name
EXTRACTED_DIR=$(find "$TMP_DIR" -name "postman" -printf '%h\n' | head -1)
EXTRACTED_DIR="$(dirname "$EXTRACTED_DIR")"

if [ -z "$EXTRACTED_DIR" ] || [ ! -d "$EXTRACTED_DIR" ]; then
    log_info "ERROR: Could not find extracted Postman directory"
    exit 1
fi

log_info "Installing Postman to $INSTALL_DIR..."
sudo rm -rf "$INSTALL_DIR"
sudo mv "$EXTRACTED_DIR" "$INSTALL_DIR"

# Create symlink for CLI access
log_info "Creating symlink at $SYMLINK..."
sudo ln -sf "$INSTALL_DIR/app/Postman" "$SYMLINK"

# Create .desktop entry so it shows up in app launchers
log_info "Creating desktop entry..."
sudo tee "$DESKTOP_FILE" > /dev/null <<EOF
[Desktop Entry]
Name=Postman
GenericName=API Client
Comment=Make and view REST API calls and responses
Exec=$INSTALL_DIR/app/Postman %U
Icon=$INSTALL_DIR/app/resources/app/assets/icon.png
Terminal=false
Type=Application
Categories=Development;Utility;
StartupWMClass=Postman
StartupNotify=true
EOF

log_info "Postman installed successfully"