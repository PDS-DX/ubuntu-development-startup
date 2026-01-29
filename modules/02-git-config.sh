#!/usr/bin/env bash
# Configure git global defaults

set -euo pipefail

CHANGED=false

set_if_unset() {
    local key="$1" value="$2"
    local current
    current="$(git config --global "$key" 2>/dev/null || true)"
    if [[ -z "$current" ]]; then
        git config --global "$key" "$value"
        log_info "Set git config: ${key} = ${value}"
        CHANGED=true
    else
        log_info "Git config '${key}' already set to '${current}'"
    fi
}

set_if_unset "init.defaultBranch" "main"
set_if_unset "pull.rebase" "true"
set_if_unset "push.autoSetupRemote" "true"
set_if_unset "core.editor" "vim"

# Prompt for name/email if not set
if [[ -z "$(git config --global user.name 2>/dev/null || true)" ]]; then
    read -rp "Enter your git user.name: " git_name
    if [[ -n "$git_name" ]]; then
        git config --global user.name "$git_name"
        CHANGED=true
    fi
fi

if [[ -z "$(git config --global user.email 2>/dev/null || true)" ]]; then
    read -rp "Enter your git user.email: " git_email
    if [[ -n "$git_email" ]]; then
        git config --global user.email "$git_email"
        CHANGED=true
    fi
fi

if ! $CHANGED; then
    log_info "Git config already configured"
    exit 2
fi

log_info "Git config updated"
