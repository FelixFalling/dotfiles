# ~/.zshenv — sourced for EVERY zsh (login, interactive, scripts, ssh commands).
# Keep this minimal: only environment that truly must exist everywhere.
#
# Maintained in: ~/Documents/dotfiles/shell/zsh/.zshenv (symlinked to ~/.zshenv)

# Default editor for all shells (interactive .zshrc may override for SSH).
export VISUAL=nvim
export EDITOR=$VISUAL
export GIT_EDITOR=$VISUAL

# Rust/Cargo toolchain on PATH — guarded so this file is harmless on machines
# without a Rust install (important for porting these dotfiles elsewhere).
[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"
