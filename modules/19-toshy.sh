#!/bin/env bash

set -euo pipefail

if is_installed toshy-versions; then
    log_info "toshy already installed: $(ngrok version)"
    exit 2
fi

# URLs
CHROME_STORE_URL="https://chromewebstore.google.com/detail/gnome-shell-integration/gphhapmejobijbbhgpjhcjognlahblep"
XREMAP_URL="https://extensions.gnome.org/extension/5060/xremap/"

echo "-------------------------------------------------------"
echo "   Toshy Installation: Pre-requisite Check"
echo "-------------------------------------------------------"
echo "To get Toshy running smoothly, we need to set up two"
echo "GNOME-related components first."
echo ""

apt_install gnome-browser-connector

# 1. GNOME Shell Integration Browser Extension
read -p "1. Do you have 'GNOME Shell Integration' installed in your browser? (y/N): " browser_ext
if [[ ! "$browser_ext" =~ ^[Yy]$ ]]; then
    echo "Opening the Chrome Web Store link..."
    xdg-open "$CHROME_STORE_URL"
    echo "Please install the extension and then return to this terminal."
    read -p "Press [Enter] once you've installed it..."
else
    echo "Perfect, skipping browser extension setup."
fi

echo ""

# 2. xremap GNOME Extension
read -p "2. Do you have the 'xremap' GNOME extension installed? (y/N): " xremap_ext
if [[ ! "$xremap_ext" =~ ^[Yy]$ ]]; then
    echo "Opening the xremap extension page..."
    xdg-open "$XREMAP_URL"
    echo "Click the toggle to 'ON' on the website to install it."
    read -p "Press [Enter] once you've toggled it on..."
else
    echo "Great, xremap is already accounted for."
fi

echo ""

# 3. Final Confirmation
read -p "Final Check: Are BOTH extensions installed and active? (y/N): " final_confirm
if [[ ! "$final_confirm" =~ ^[Yy]$ ]]; then
    echo "Error: Pre-requisites not met. Exiting script."
    exit 1
fi

echo "Success! Requirements verified. Proceeding with the rest of the installation..."

apt update && apt upgrade -y

git clone https://github.com/RedBearAK/Toshy.git
./Toshy/setup_toshy.py install

rm -rf Toshy