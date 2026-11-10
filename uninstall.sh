#!/usr/bin/env bash
#
# uninstall.sh — remove symlinks created by install.sh, and (optionally) restore
#                the files that install.sh backed up.
#
# Usage:
#   ./uninstall.sh             # remove our symlinks; restore the most recent backup
#   ./uninstall.sh --no-restore   # just remove the symlinks, leave nothing behind
#   ./uninstall.sh --dry-run      # print what WOULD happen, change nothing
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DOTFILES/lib/links.sh"

DRY_RUN=0
RESTORE=1
for arg in "$@"; do
  case "$arg" in
    --dry-run)    DRY_RUN=1 ;;
    --no-restore) RESTORE=0 ;;
    -h|--help)    sed -n '3,11p' "$0"; exit 0 ;;
    *) echo "Unknown option: $arg" >&2; exit 2 ;;
  esac
done

say() { printf '%s\n' "$*"; }
run() { if [[ $DRY_RUN -eq 1 ]]; then say "  [dry-run] $*"; else "$@"; fi; }

ALL_LINKS=( "${CORE_LINKS[@]}" "${LINUX_LINKS[@]}" "${NVIM_LINKS[@]}" )

say "Removing symlinks that point into this repo..."
for entry in "${ALL_LINKS[@]}"; do
  src="$DOTFILES/${entry%%::*}"
  dest="$HOME/${entry##*::}"
  if [[ -L "$dest" && "$(readlink -- "$dest")" == "$src" ]]; then
    run rm "$dest"
    say "  - removed ~/${entry##*::}"
  fi
done

if [[ $RESTORE -eq 1 ]]; then
  latest="$(ls -1d "$DOTFILES"/.backups/*/ 2>/dev/null | sort | tail -1 || true)"
  if [[ -n "${latest:-}" ]]; then
    say ""
    say "Restoring most recent backup: ${latest/#$HOME/~}"
    # Walk every file/dir in the snapshot and move it back to the same path under $HOME.
    while IFS= read -r -d '' item; do
      rel="${item#"$latest"}"
      dest="$HOME/$rel"
      run mkdir -p "$(dirname "$dest")"
      run mv "$item" "$dest"
      say "  + restored ~/$rel"
    done < <(find "$latest" -mindepth 1 \( -type f -o -type l \) -print0)
  else
    say ""
    say "No backups found to restore (nothing in .backups/)."
  fi
fi

say ""
say "Done. Open a new shell to pick up the changes."
