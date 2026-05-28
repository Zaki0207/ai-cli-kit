#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
SETTINGS="$CLAUDE_DIR/settings.json"
SCRIPT_DEST="$CLAUDE_DIR/statusline-command.sh"

# ── Dependency check ──────────────────────────────────────────────────────────
for cmd in jq bc git; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Error: '$cmd' is required but not installed." >&2
    exit 1
  fi
done

# ── Install script ────────────────────────────────────────────────────────────
mkdir -p "$CLAUDE_DIR"
cp "$REPO_DIR/statusline-command.sh" "$SCRIPT_DEST"
chmod +x "$SCRIPT_DEST"
echo "Installed: $SCRIPT_DEST"

# ── Merge statusLine into settings.json ───────────────────────────────────────
STATUS_LINE_CONFIG='{"type":"command","command":"bash $HOME/.claude/statusline-command.sh"}'

if [ -f "$SETTINGS" ]; then
  # Merge into existing settings — preserve all other keys
  tmp=$(mktemp)
  jq --argjson sl "$STATUS_LINE_CONFIG" '. + {statusLine: $sl}' "$SETTINGS" > "$tmp"
  mv "$tmp" "$SETTINGS"
  echo "Updated:   $SETTINGS"
else
  # Create minimal settings file
  jq -n --argjson sl "$STATUS_LINE_CONFIG" '{statusLine: $sl}' > "$SETTINGS"
  echo "Created:   $SETTINGS"
fi

echo ""
echo "Done. Restart Claude Code to see the status bar."
