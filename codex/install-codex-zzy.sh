#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Install the codex-zzy command for ChatGPT subscription Codex.

Usage:
  ./codex/install-codex-zzy.sh [--dry-run] [--no-rc]

Options:
  --dry-run  Print the actions without writing files.
  --no-rc    Do not update ~/.zshrc, ~/.bashrc, or ~/.profile.
  -h, --help Show this help.
EOF
}

dry_run=0
update_rc=1

while [ "$#" -gt 0 ]; do
  case "$1" in
    --dry-run)
      dry_run=1
      ;;
    --no-rc)
      update_rc=0
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf 'install-codex-zzy: unknown option: %s\n' "$1" >&2
      usage >&2
      exit 2
      ;;
  esac
  shift
done

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
install_dir="$HOME/.local/bin"
official_home="$HOME/.codex-zzy-official"
src_official="$script_dir/codex-official"
src_zzy="$script_dir/codex-zzy"

if [ ! -f "$src_official" ] || [ ! -f "$src_zzy" ]; then
  printf 'install-codex-zzy: run this script from the ai-cli-kit repository checkout.\n' >&2
  exit 1
fi

run() {
  if [ "$dry_run" -eq 1 ]; then
    printf '+'
    printf ' %q' "$@"
    printf '\n'
  else
    "$@"
  fi
}

detect_rc_file() {
  case "${SHELL:-}" in
    */zsh)
      printf '%s\n' "$HOME/.zshrc"
      ;;
    */bash)
      printf '%s\n' "$HOME/.bashrc"
      ;;
    *)
      if [ -f "$HOME/.zshrc" ]; then
        printf '%s\n' "$HOME/.zshrc"
      elif [ -f "$HOME/.bashrc" ]; then
        printf '%s\n' "$HOME/.bashrc"
      else
        printf '%s\n' "$HOME/.profile"
      fi
      ;;
  esac
}

install_path_block() {
  rc_file="$(detect_rc_file)"
  marker_start="# >>> ai-cli-kit codex-zzy >>>"
  marker_end="# <<< ai-cli-kit codex-zzy <<<"

  if [ -f "$rc_file" ] && grep -Fq "$marker_start" "$rc_file"; then
    printf 'PATH block already exists in %s\n' "$rc_file"
    return
  fi

  if [ "$dry_run" -eq 1 ]; then
    printf '+ append codex-zzy PATH block to %s\n' "$rc_file"
    return
  fi

  mkdir -p "$(dirname "$rc_file")"
  touch "$rc_file"
  cat >>"$rc_file" <<EOF

$marker_start
case ":\$PATH:" in
  *":\$HOME/.local/bin:"*) ;;
  *) export PATH="\$HOME/.local/bin:\$PATH" ;;
esac
$marker_end
EOF

  printf 'Updated shell rc: %s\n' "$rc_file"
}

run mkdir -p "$install_dir"
run mkdir -p "$official_home"
run chmod 700 "$official_home"
run cp "$src_official" "$install_dir/codex-official"
run cp "$src_zzy" "$install_dir/codex-zzy"
run chmod 755 "$install_dir/codex-official" "$install_dir/codex-zzy"

if [ "$update_rc" -eq 1 ]; then
  install_path_block
else
  printf 'Skipped shell rc update because --no-rc was set.\n'
fi

if [ "$dry_run" -eq 1 ]; then
  result_message="Dry run complete. No files were changed."
else
  result_message="Installed codex-zzy."
fi

cat <<EOF

$result_message

Command:
  $install_dir/codex-zzy

Official subscription Codex home:
  $official_home

Default codex is unchanged and will still read:
  $HOME/.codex/config.toml

Next:
  codex-zzy login --device-auth
  codex-zzy

If the command is not found in the current terminal, open a new shell or run:
  export PATH="\$HOME/.local/bin:\$PATH"
EOF
