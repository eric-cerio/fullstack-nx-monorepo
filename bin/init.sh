#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TARGET_DIR=""
DRY_RUN=false

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

usage() {
  echo "Usage: bash bin/init.sh [OPTIONS] <target-directory>"
  echo ""
  echo "Install the governance framework into an Nx monorepo."
  echo ""
  echo "Options:"
  echo "  --dry-run    Preview actions without making changes"
  echo "  --help       Show this help message"
  echo ""
  echo "Examples:"
  echo "  bash bin/init.sh /path/to/my-nx-workspace"
  echo "  bash bin/init.sh --dry-run ."
}

log_ok()   { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_err()  { echo -e "${RED}[ERROR]${NC} $1"; }
log_skip() { echo -e "${YELLOW}[SKIP]${NC} $1"; }

run() {
  if [ "$DRY_RUN" = true ]; then
    echo "  [dry-run] $1"
  else
    eval "$2"
  fi
}

# Parse arguments
for arg in "$@"; do
  case $arg in
    --dry-run) DRY_RUN=true ;;
    --help) usage; exit 0 ;;
    -*) echo "Unknown option: $arg"; usage; exit 1 ;;
    *) TARGET_DIR="$arg" ;;
  esac
done

if [ -z "$TARGET_DIR" ]; then
  echo "Error: No target directory specified."
  echo ""
  usage
  exit 1
fi

TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"

echo "=== Nx Governance Framework Installer ==="
echo "Framework source: $SCRIPT_DIR"
echo "Target workspace: $TARGET_DIR"
if [ "$DRY_RUN" = true ]; then
  echo -e "${YELLOW}(dry run — no changes will be made)${NC}"
fi
echo ""

# 1. Detect Nx workspace
if [ ! -f "$TARGET_DIR/nx.json" ]; then
  log_err "nx.json not found in $TARGET_DIR"
  echo "    This script must be run against an Nx workspace root."
  echo "    Create one with: npx create-nx-workspace"
  exit 1
fi
log_ok "Nx workspace detected"

# 2. Check package manager
if [ -f "$TARGET_DIR/pnpm-lock.yaml" ]; then
  log_ok "pnpm detected"
elif [ -f "$TARGET_DIR/package-lock.json" ]; then
  log_warn "npm lockfile found — this framework enforces pnpm"
  echo "    Consider migrating: rm package-lock.json && pnpm install"
elif [ -f "$TARGET_DIR/yarn.lock" ]; then
  log_warn "yarn lockfile found — this framework enforces pnpm"
  echo "    Consider migrating: rm yarn.lock && pnpm install"
else
  log_warn "No lockfile found — run 'pnpm install' after setup"
fi

# 3. Copy framework directories
echo ""
echo "--- Copying framework files ---"
for dir in agents rules commands skills hooks; do
  if [ -d "$TARGET_DIR/$dir" ]; then
    log_skip "$dir/ already exists (will merge)"
  fi
  run "Copy $dir/" "cp -r '$SCRIPT_DIR/$dir' '$TARGET_DIR/$dir'"
  log_ok "Copied $dir/"
done

# 4. Copy config files
run "Copy config.yml" "cp '$SCRIPT_DIR/config.yml' '$TARGET_DIR/config.yml'"
log_ok "Copied config.yml"

if [ -d "$SCRIPT_DIR/config" ]; then
  run "Copy config/" "cp -r '$SCRIPT_DIR/config' '$TARGET_DIR/config'"
  log_ok "Copied config/"
fi

if [ -d "$SCRIPT_DIR/pipelines" ]; then
  run "Copy pipelines/" "cp -r '$SCRIPT_DIR/pipelines' '$TARGET_DIR/pipelines'"
  log_ok "Copied pipelines/"
fi

# 5. Copy CLAUDE.md (don't overwrite existing)
echo ""
echo "--- Setting up project files ---"
if [ -f "$TARGET_DIR/CLAUDE.md" ]; then
  log_skip "CLAUDE.md already exists — not overwriting"
else
  run "Copy CLAUDE.md" "cp '$SCRIPT_DIR/examples/CLAUDE.md' '$TARGET_DIR/CLAUDE.md'"
  log_ok "Copied CLAUDE.md from examples/"
fi

# 6. Create required directories
echo ""
echo "--- Creating required directories ---"
for d in docs/features docs/session-logs database/migrations; do
  run "Create $d/" "mkdir -p '$TARGET_DIR/$d'"
  log_ok "Created $d/"
done
run "Create .gitkeep files" "touch '$TARGET_DIR/docs/session-logs/.gitkeep' '$TARGET_DIR/docs/features/.gitkeep' '$TARGET_DIR/database/migrations/.gitkeep'"

# 7. Set up Claude Code hooks
echo ""
echo "--- Configuring Claude Code hooks ---"
run "Create .claude/" "mkdir -p '$TARGET_DIR/.claude'"
if [ -f "$TARGET_DIR/.claude/hooks.json" ]; then
  log_skip ".claude/hooks.json already exists"
else
  run "Symlink hooks" "ln -sf '../hooks/hooks.json' '$TARGET_DIR/.claude/hooks.json'"
  log_ok "Linked .claude/hooks.json → hooks/hooks.json"
fi

# 8. Summary
echo ""
echo "=== Installation Complete ==="
echo ""
echo "Next steps:"
echo "  1. Review and customize config.yml for your stack"
echo "  2. Review and customize CLAUDE.md for your project"
echo "  3. Review config/overrides.yml and set active_profile"
echo "  4. Open Claude Code in your workspace and try: /plan"
echo ""
echo "Available commands:"
echo "  /plan            — Plan a new feature"
echo "  /tdd             — Start test-driven development"
echo "  /code-review     — Review code"
echo "  /status          — Project health dashboard"
echo "  /full-review     — Comprehensive review pipeline"
echo ""
echo "Validate the framework:"
echo "  bash $TARGET_DIR/bin/validate.sh"
