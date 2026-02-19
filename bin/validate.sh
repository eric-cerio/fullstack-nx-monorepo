#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ERRORS=0
WARNINGS=0

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_ok()   { echo -e "  ${GREEN}[OK]${NC} $1"; }
log_err()  { echo -e "  ${RED}[ERROR]${NC} $1"; ERRORS=$((ERRORS + 1)); }
log_warn() { echo -e "  ${YELLOW}[WARN]${NC} $1"; WARNINGS=$((WARNINGS + 1)); }

echo "=== Governance Framework Validator ==="
echo "Root: $ROOT"
echo ""

# ─────────────────────────────────────────
# 1. Validate agent YAML frontmatter
# ─────────────────────────────────────────
echo "--- Checking agent frontmatter ---"
agent_count=0
for agent in "$ROOT"/agents/*.md; do
  [ -f "$agent" ] || continue
  name=$(basename "$agent" .md)
  agent_count=$((agent_count + 1))

  # Check for YAML frontmatter delimiters
  first_line=$(head -1 "$agent")
  if [ "$first_line" != "---" ]; then
    log_err "$name: Missing YAML frontmatter (no opening ---)"
    continue
  fi

  # Extract frontmatter (between first and second ---)
  frontmatter=$(sed -n '2,/^---$/p' "$agent" | grep -v '^---$')

  for field in name description tools model; do
    if ! echo "$frontmatter" | grep -q "^${field}:"; then
      log_err "$name: Missing frontmatter field '$field'"
    fi
  done

  # Check model is valid
  model_value=$(echo "$frontmatter" | grep '^model:' | sed 's/model: *//' | tr -d '[:space:]')
  if [ -n "$model_value" ]; then
    case "$model_value" in
      opus|sonnet|haiku) ;;
      *) log_warn "$name: Unusual model value '$model_value' (expected: opus, sonnet, haiku)" ;;
    esac
  fi

  log_ok "$name"
done
echo "  Agents checked: $agent_count"
echo ""

# ─────────────────────────────────────────
# 2. Validate command frontmatter
# ─────────────────────────────────────────
echo "--- Checking command frontmatter ---"
cmd_count=0
for cmd in "$ROOT"/commands/*.md; do
  [ -f "$cmd" ] || continue
  cmd_name=$(basename "$cmd" .md)
  cmd_count=$((cmd_count + 1))

  first_line=$(head -1 "$cmd")
  if [ "$first_line" != "---" ]; then
    log_err "command/$cmd_name: Missing YAML frontmatter (no opening ---)"
    continue
  fi

  # Check for description field
  frontmatter=$(sed -n '2,/^---$/p' "$cmd" | grep -v '^---$')
  if ! echo "$frontmatter" | grep -q "^description:"; then
    log_warn "command/$cmd_name: Missing 'description' in frontmatter"
  fi

  log_ok "$cmd_name"
done
echo "  Commands checked: $cmd_count"
echo ""

# ─────────────────────────────────────────
# 3. Validate hooks.json
# ─────────────────────────────────────────
echo "--- Checking hooks.json ---"
hooks_file="$ROOT/hooks/hooks.json"

if [ ! -f "$hooks_file" ]; then
  log_err "hooks/hooks.json not found"
else
  # Validate JSON syntax
  if command -v jq >/dev/null 2>&1; then
    if jq empty "$hooks_file" 2>/dev/null; then
      log_ok "Valid JSON syntax"
    else
      log_err "hooks.json has invalid JSON syntax"
    fi

    # Count hooks per type
    for hook_type in PreToolUse PostToolUse Stop; do
      count=$(jq -r ".hooks.${hook_type} | length" "$hooks_file" 2>/dev/null || echo "0")
      echo "  $hook_type hooks: $count"
    done

    # Check all hooks have descriptions
    missing_desc=$(jq -r '.hooks | to_entries[] | .value[] | select(.description == null or .description == "") | .matcher' "$hooks_file" 2>/dev/null || true)
    if [ -n "$missing_desc" ]; then
      log_warn "Some hooks are missing descriptions"
    fi
  else
    log_warn "jq not installed — skipping detailed hook validation"
    echo "  Install jq: brew install jq"
  fi
fi
echo ""

# ─────────────────────────────────────────
# 4. Check config.yml exists
# ─────────────────────────────────────────
echo "--- Checking config files ---"
if [ -f "$ROOT/config.yml" ]; then
  log_ok "config.yml exists"
  # Check version field
  if grep -q '^version:' "$ROOT/config.yml"; then
    version=$(grep '^version:' "$ROOT/config.yml" | sed 's/version: *"//' | sed 's/"//')
    echo "  Framework version: $version"
  else
    log_warn "config.yml missing 'version' field"
  fi
else
  log_warn "config.yml not found"
fi

if [ -f "$ROOT/config/overrides.yml" ]; then
  log_ok "config/overrides.yml exists"
else
  log_warn "config/overrides.yml not found"
fi
echo ""

# ─────────────────────────────────────────
# 5. Check skills exist
# ─────────────────────────────────────────
echo "--- Checking skills ---"
skill_count=0
for skill in "$ROOT"/skills/*.md; do
  [ -f "$skill" ] || continue
  skill_count=$((skill_count + 1))
done
echo "  Skills found: $skill_count"
if [ "$skill_count" -eq 0 ]; then
  log_warn "No skill files found in skills/"
fi
echo ""

# ─────────────────────────────────────────
# 6. Check rules exist
# ─────────────────────────────────────────
echo "--- Checking rules ---"
rule_count=0
for rule in "$ROOT"/rules/*.md; do
  [ -f "$rule" ] || continue
  rule_count=$((rule_count + 1))
done
echo "  Rules found: $rule_count"
if [ "$rule_count" -eq 0 ]; then
  log_warn "No rule files found in rules/"
fi
echo ""

# ─────────────────────────────────────────
# 7. Check required directories
# ─────────────────────────────────────────
echo "--- Checking directory structure ---"
for dir in agents rules commands skills hooks; do
  if [ -d "$ROOT/$dir" ]; then
    log_ok "$dir/ exists"
  else
    log_err "$dir/ missing"
  fi
done
echo ""

# ─────────────────────────────────────────
# Summary
# ─────────────────────────────────────────
echo "=== Validation Complete ==="
echo -e "  Errors:   ${RED}$ERRORS${NC}"
echo -e "  Warnings: ${YELLOW}$WARNINGS${NC}"
echo ""
if [ "$ERRORS" -eq 0 ]; then
  echo -e "  ${GREEN}STATUS: PASS${NC}"
else
  echo -e "  ${RED}STATUS: FAIL${NC}"
fi

exit "$ERRORS"
