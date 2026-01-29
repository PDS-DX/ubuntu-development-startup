# Developer Environment Setup

Modular, idempotent bash scripts for setting up a complete developer environment on Ubuntu.

## Quick Start

```bash
chmod +x setup.sh
./setup.sh          # Run all modules
./setup.sh --list   # List available modules
./setup.sh --dry-run  # Preview what would run
./setup.sh --module 01-core-tools --module 05-docker  # Run specific modules
```

## Architecture

- `setup.sh` — orchestrator with arg parsing (`--all`, `--module`, `--list`, `--dry-run`)
- `lib/common.sh` — logging, idempotency checks, APT helpers, `add_apt_repo_deb822()`
- `lib/config.sh` — pinned versions, Ubuntu codename detection with LTS fallback
- `modules/XX-name.sh` — one file per tool/category, sourced by the orchestrator

## Conventions

- All scripts use `set -euo pipefail`
- Each module checks if its tool is already installed and exits with code 2 to signal "skipped"
- Exit code 0 = installed/updated, exit code 2 = already present, other = failure
- APT repos use DEB822 `.sources` format with keys in `/usr/share/keyrings/`
- Shell config blocks use `# >>> dev-setup: name >>>` / `# <<< dev-setup: name <<<` markers
- Non-LTS Ubuntu codenames fall back to "noble" for repos that only publish LTS suites
- Logs are written to `/tmp/dev-setup-YYYYMMDD-HHMMSS.log`

## Module Dependencies

- Module 09 (Claude Code) depends on module 04 (nvm/Node.js) for npm
- Module 20 (shell-config) should run last as it configures completions for other tools

## Pinned Versions (lib/config.sh)

Update version pins in `lib/config.sh` when upgrading tools.
