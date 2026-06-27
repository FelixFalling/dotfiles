#!/usr/bin/env bash
# lib/links.sh — the single source of truth for "which repo file goes where".
#
# Sourced by install.sh and uninstall.sh. Each entry is:
#     <path inside repo>::<destination relative to $HOME>
#
# Keep destinations relative to $HOME (no leading ~ or /). Parent directories
# are created automatically by install.sh.

# Cross-platform core: shells, multiplexer, editors, git, terminal, CLI tools.
CORE_LINKS=(
  "shell/zsh/.zshrc::.zshrc"
  "shell/zsh/.zshenv::.zshenv"
  "shell/zsh/.p10k.zsh::.p10k.zsh"
  "shell/bash/.bashrc::.bashrc"
  "shell/bash/.bash_profile::.bash_profile"
  "shell/bash/.bash_logout::.bash_logout"
  "shell/bash/.profile::.profile"
  "tmux/.tmux.conf::.tmux.conf"
  "editors/vim/.vimrc::.vimrc"
  "git/.gitconfig::.gitconfig"
  "git/gitignore_global::.config/git/ignore"
  "debug/.gdbinit::.gdbinit"
  "terminal/alacritty/alacritty.toml::.config/alacritty/alacritty.toml"
  "terminal/cool-retro-term/cool-retro-term.conf::.config/cool-retro-term/cool-retro-term.conf"
  "cli-tools/btop/btop.conf::.config/btop/btop.conf"
  "cli-tools/htop/htoprc::.config/htop/htoprc"
)

# Linux desktop only — skipped automatically on macOS / Windows.
LINUX_LINKS=(
  "linux-desktop/gtk/.gtkrc-2.0::.gtkrc-2.0"
  "linux-desktop/niri/config.kdl::.config/niri/config.kdl"
)

# Neovim (NvChad). Opt-in via `--nvim` because upstream is normally its own git
# repo; symlinking the whole dir makes THIS repo the source of truth instead.
NVIM_LINKS=(
  "editors/nvim::.config/nvim"
)
