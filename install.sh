#!/usr/bin/env bash
#
# install.sh — symlink these dotfiles into place, backing up anything already there.
#
# Usage:
#   ./install.sh                 # link core (+ Linux desktop configs when on Linux)
#   ./install.sh --nvim          # also link the Neovim config (~/.config/nvim)
#   ./install.sh --core-only     # link only the cross-platform core (skip Linux desktop)
#   ./install.sh --dry-run       # print what WOULD happen, change nothing
#
# Existing files are moved to .backups/<timestamp>/ before a symlink is created,
# so this is fully reversible — see ./uninstall.sh.
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DOTFILES/lib/links.sh"

# ---- options ----------------------------------------------------------------
DRY_RUN=0
WITH_NVIM=0
CORE_ONLY=0
for arg in "$@"; do
  case "$arg" in
    --dry-run)   DRY_RUN=1 ;;
    --nvim)      WITH_NVIM=1 ;;
    --core-only) CORE_ONLY=1 ;;
    -h|--help)   sed -n '3,14p' "$0"; exit 0 ;;
    *) echo "Unknown option: $arg" >&2; exit 2 ;;
  esac
done

case "$(uname -s)" in
  Linux)  IS_LINUX=1 ;;
  *)      IS_LINUX=0 ;;
esac

STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$DOTFILES/.backups/$STAMP"

say()  { printf '%s\n' "$*"; }
run()  { if [[ $DRY_RUN -eq 1 ]]; then say "  [dry-run] $*"; else eval "$*"; fi; }

# link <repo-relative-src> <home-relative-dest>
link() {
  local src="$DOTFILES/$1" dest="$HOME/$2"

  if [[ ! -e "$src" ]]; then
    say "  ! skip (missing in repo): $1"
    return
  fi

  # Already the correct symlink? Nothing to do.
  if [[ -L "$dest" && "$(readlink -- "$dest")" == "$src" ]]; then
    say "  = ok (already linked): ~/$2"
    return
  fi

  # Back up whatever is currently there (real file, dir, or stale symlink).
  if [[ -e "$dest" || -L "$dest" ]]; then
    local backup="$BACKUP_DIR/$2"
    run "mkdir -p '$(dirname "$backup")'"
    run "mv '$dest' '$backup'"
    say "  ~ backed up existing ~/$2"
  fi

  run "mkdir -p '$(dirname "$dest")'"
  run "ln -s '$src' '$dest'"
  say "  + linked ~/$2  ->  ${src/#$HOME/~}"
}

# ---- run --------------------------------------------------------------------
say "dotfiles: $DOTFILES"
[[ $DRY_RUN -eq 1 ]] && say "(dry run — nothing will be changed)"
say ""

say "Core (cross-platform):"
for entry in "${CORE_LINKS[@]}"; do link "${entry%%::*}" "${entry##*::}"; done

if [[ $CORE_ONLY -eq 0 && $IS_LINUX -eq 1 ]]; then
  say ""
  say "Linux desktop:"
  for entry in "${LINUX_LINKS[@]}"; do link "${entry%%::*}" "${entry##*::}"; done
elif [[ $CORE_ONLY -eq 0 ]]; then
  say ""
  say "Linux desktop: skipped (not on Linux)"
fi

if [[ $WITH_NVIM -eq 1 ]]; then
  say ""
  say "Neovim:"
  for entry in "${NVIM_LINKS[@]}"; do link "${entry%%::*}" "${entry##*::}"; done
fi

say ""
if [[ $DRY_RUN -eq 0 && -d "$BACKUP_DIR" ]]; then
  say "Replaced files were backed up to: ${BACKUP_DIR/#$HOME/~}"
fi
say "Done. Open a new shell (or run: exec zsh) to pick up the changes."
