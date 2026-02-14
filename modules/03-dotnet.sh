#!/usr/bin/env bash
# Install .NET SDK via Microsoft APT repo

set -euo pipefail

if is_installed dotnet && dotnet --list-sdks | grep -q "^${DOTNET_CHANNEL}"; then
    log_info ".NET SDK ${DOTNET_CHANNEL} already installed"
    exit 2
fi

curl -sSL https://dot.net/v1/dotnet-install.sh -o dotnet-install.sh

bash dotnet-install.sh --channel 10.0
bash dotnet-install.sh --channel 9.0
bash dotnet-install.sh --channel 8.0

rm dotnet-install.sh

# 1. Add the installation directory to the path
echo 'export DOTNET_ROOT=$HOME/.dotnet' >> ~/.bashrc

# 2. Add the dotnet tool to the system PATH
echo 'export PATH=$PATH:$HOME/.dotnet:$HOME/.dotnet/tools' >> ~/.bashrc

# 3. Apply changes to the current terminal
source ~/.bashrc

log_info ".NET SDKs installed: $(dotnet --list-sdks)"
