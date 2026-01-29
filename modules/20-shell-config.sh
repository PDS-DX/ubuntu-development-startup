#!/usr/bin/env bash
# Shell completions + PATH additions for .bashrc

set -euo pipefail

BASHRC="${HOME}/.bashrc"
CHANGED=false

# Append a marker-guarded block to .bashrc
# Usage: add_bashrc_block <marker_name> <content>
add_bashrc_block() {
    local marker="$1"
    local content="$2"
    local start_marker="# >>> dev-setup: ${marker} >>>"
    local end_marker="# <<< dev-setup: ${marker} <<<"

    if grep -qF "$start_marker" "$BASHRC" 2>/dev/null; then
        log_info "bashrc block '${marker}' already present, skipping"
        return 0
    fi

    log_info "Adding bashrc block: ${marker}"
    cat >> "$BASHRC" <<EOF

${start_marker}
${content}
${end_marker}
EOF
    CHANGED=true
}

# --- nvm ---
add_bashrc_block "nvm" 'export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"'

# --- kubectl completion ---
add_bashrc_block "kubectl" 'if command -v kubectl &>/dev/null; then
    source <(kubectl completion bash)
    alias k=kubectl
    complete -o default -F __start_kubectl k
fi'

# --- gh completion ---
add_bashrc_block "gh" 'if command -v gh &>/dev/null; then
    eval "$(gh completion -s bash)"
fi'

# --- AWS CLI completion ---
add_bashrc_block "aws" 'if command -v aws_completer &>/dev/null; then
    complete -C "$(which aws_completer)" aws
fi'

# --- Pulumi ---
add_bashrc_block "pulumi" 'export PATH="$HOME/.pulumi/bin:$PATH"
if command -v pulumi &>/dev/null; then
    eval "$(pulumi gen-completion bash 2>/dev/null || true)"
fi'

# --- local bin ---
add_bashrc_block "local-bin" 'export PATH="$HOME/.local/bin:$PATH"'

# --- JetBrains Toolbox ---
add_bashrc_block "jetbrains" 'export PATH="$HOME/.local/share/JetBrains/Toolbox/bin:$PATH"'

# --- bat alias (Ubuntu names it batcat) ---
add_bashrc_block "bat" 'if command -v batcat &>/dev/null && ! command -v bat &>/dev/null; then
    alias bat=batcat
fi'

# --- fd alias (Ubuntu names it fdfind) ---
add_bashrc_block "fd" 'if command -v fdfind &>/dev/null && ! command -v fd &>/dev/null; then
    alias fd=fdfind
fi'

if ! $CHANGED; then
    log_info "Shell config already up to date"
    exit 2
fi

log_info "Shell config updated — run 'source ~/.bashrc' or open a new terminal"
