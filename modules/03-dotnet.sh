#!/usr/bin/env bash
# Install .NET SDK via Microsoft APT repo

set -euo pipefail

if is_installed dotnet && dotnet --list-sdks | grep -q "^${DOTNET_CHANNEL}"; then
    log_info ".NET SDK ${DOTNET_CHANNEL} already installed"
    exit 2
fi

SUITE="$(lts_suite)"

add_apt_repo_deb822 "microsoft" \
    "https://packages.microsoft.com/ubuntu/${SUITE}/prod" \
    "https://packages.microsoft.com/keys/microsoft.asc" \
    "$SUITE" \
    "main"

apt_install "dotnet-sdk-${DOTNET_CHANNEL}"

log_info ".NET SDK installed: $(dotnet --version)"
