#!/usr/bin/env bash
# Main entry point — orchestrates all setup modules

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"
# shellcheck source=lib/config.sh
source "${SCRIPT_DIR}/lib/config.sh"

# --- Argument Parsing ---

RUN_ALL=true
DRY_RUN=false
SELECTED_MODULES=()

usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Options:
  --all              Run all modules (default)
  --module <name>    Run specific module (repeatable, e.g. --module 01-core-tools)
  --list             List available modules and exit
  --dry-run          Show what would be run without executing
  -h, --help         Show this help

Examples:
  $(basename "$0")                              # Run all modules
  $(basename "$0") --module 01-core-tools       # Run single module
  $(basename "$0") --module 03-dotnet --module 05-docker
  $(basename "$0") --dry-run                    # Preview execution plan
EOF
}

list_modules() {
    log_section "Available Modules"
    for module in "${SCRIPT_DIR}"/modules/*.sh; do
        local name
        name="$(basename "$module" .sh)"
        echo "  $name"
    done
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --all)
            RUN_ALL=true
            shift
            ;;
        --module)
            [[ -z "${2:-}" ]] && { log_error "--module requires an argument"; exit 1; }
            RUN_ALL=false
            SELECTED_MODULES+=("$2")
            shift 2
            ;;
        --list)
            list_modules
            exit 0
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# --- Gather modules to run ---

MODULES_TO_RUN=()

if $RUN_ALL; then
    for module in "${SCRIPT_DIR}"/modules/*.sh; do
        MODULES_TO_RUN+=("$module")
    done
else
    for name in "${SELECTED_MODULES[@]}"; do
        local_path="${SCRIPT_DIR}/modules/${name}.sh"
        if [[ -f "$local_path" ]]; then
            MODULES_TO_RUN+=("$local_path")
        else
            log_error "Module not found: ${name}"
            exit 1
        fi
    done
fi

if [[ ${#MODULES_TO_RUN[@]} -eq 0 ]]; then
    log_error "No modules found"
    exit 1
fi

# --- Dry run ---

if $DRY_RUN; then
    log_section "Dry Run — Modules to execute"
    for module in "${MODULES_TO_RUN[@]}"; do
        echo "  $(basename "$module" .sh)"
    done
    echo ""
    log_info "Log would be written to: $LOG_FILE"
    exit 0
fi

# --- Execute ---

log_section "Developer Environment Setup"
log_info "Log file: $LOG_FILE"

detect_arch
detect_codename
ensure_sudo

INSTALLED_MODULES=()
SKIPPED_MODULES=()
FAILED_MODULES=()

for module in "${MODULES_TO_RUN[@]}"; do
    module_name="$(basename "$module" .sh)"
    log_section "$module_name"

    set +e
    (
        set -euo pipefail
        source "$module"
    )
    exit_code=$?
    set -e

    if [[ $exit_code -eq 0 ]]; then
        INSTALLED_MODULES+=("$module_name")
    elif [[ $exit_code -eq 2 ]]; then
        # Convention: exit 2 means "already installed / skipped"
        SKIPPED_MODULES+=("$module_name")
    else
        FAILED_MODULES+=("$module_name")
        # Abort on core-tools failure
        if [[ "$module_name" == "01-core-tools" ]]; then
            log_error "Critical module '${module_name}' failed — aborting"
            exit 1
        fi
        log_warn "Module '${module_name}' failed (exit code ${exit_code}), continuing..."
    fi
done

# --- Summary ---

log_section "Setup Summary"

if [[ ${#INSTALLED_MODULES[@]} -gt 0 ]]; then
    log_info "Installed/Updated (${#INSTALLED_MODULES[@]}):"
    for m in "${INSTALLED_MODULES[@]}"; do echo "  ✓ $m"; done
fi

if [[ ${#SKIPPED_MODULES[@]} -gt 0 ]]; then
    log_info "Skipped — already installed (${#SKIPPED_MODULES[@]}):"
    for m in "${SKIPPED_MODULES[@]}"; do echo "  - $m"; done
fi

if [[ ${#FAILED_MODULES[@]} -gt 0 ]]; then
    log_error "Failed (${#FAILED_MODULES[@]}):"
    for m in "${FAILED_MODULES[@]}"; do echo "  ✗ $m"; done
    echo ""
    log_warn "Review the log for details: $LOG_FILE"
    exit 1
fi

echo ""
log_info "All done! Log saved to: $LOG_FILE"
log_info "You may need to log out and back in for group changes (e.g. docker) to take effect."
