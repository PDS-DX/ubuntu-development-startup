#!/usr/bin/env bash
# Install DBeaver Community Edition via APT repo

set -euo pipefail

if is_installed dbeaver || is_apt_installed dbeaver-ce; then
    log_info "DBeaver already installed"
    exit 2
fi

log_info "Installing DBeaver..."

add_apt_repo_deb822 "dbeaver" \
    "https://dbeaver.io/debs/dbeaver-ce" \
    "https://dbeaver.io/debs/dbeaver.gpg.key" \
    "/" \
    ""

apt_update_if_needed
sudo apt install dbeaver-ce

log_info "DBeaver installed"
