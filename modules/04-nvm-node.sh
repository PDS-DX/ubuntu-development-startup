#!/usr/bin/env bash
# Install nvm, Node.js LTS, and global npm packages

set -euo pipefail

export NVM_DIR="${HOME}/.nvm"

# Check for existing nodesource apt repo
if [[ -f /etc/apt/sources.list.d/nodesource.list ]] || [[ -f /etc/apt/sources.list.d/nodesource.sources ]]; then
    log_warn "NodeSource APT repo detected — nvm will manage Node.js versions separately"
fi

# Install nvm if not present
if [[ ! -d "$NVM_DIR" ]]; then
    log_info "Installing nvm v${NVM_VERSION}..."
    curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/v${NVM_VERSION}/install.sh" | bash
else
    log_info "nvm already installed"
fi

# Source nvm for this session
# shellcheck source=/dev/null
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"

# Install Node.js LTS
if nvm ls "$NODE_VERSION" &>/dev/null; then
    log_info "Node.js ${NODE_VERSION} already installed via nvm"
else
    log_info "Installing Node.js ${NODE_VERSION} via nvm..."
    nvm install "$NODE_VERSION"
fi

nvm alias default "$NODE_VERSION"
nvm use default

# Install global npm packages
GLOBAL_PACKAGES=(typescript ts-node)
for pkg in "${GLOBAL_PACKAGES[@]}"; do
    if npm list -g "$pkg" &>/dev/null; then
        log_info "npm global package '${pkg}' already installed"
    else
        log_info "Installing npm global package: ${pkg}"
        npm install -g "$pkg"
    fi
done

log_info "Node.js setup complete: $(node --version), npm $(npm --version)"
