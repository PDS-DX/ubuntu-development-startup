#!/usr/bin/env bash
# Install Claude Code via npm global install

set -euo pipefail

export NVM_DIR="${HOME}/.nvm"
# shellcheck source=/dev/null
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"

if ! is_installed npm; then
    log_error "npm not found — module 04-nvm-node must run first"
    exit 1
fi

if npm list -g @anthropic-ai/claude-code &>/dev/null; then
    log_info "Claude Code already installed"
    exit 2
fi

log_info "Installing Claude Code..."
npm install -g @anthropic-ai/claude-code

log_info "Claude Code installed"
