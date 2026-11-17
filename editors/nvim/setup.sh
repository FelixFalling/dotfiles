#!/usr/bin/env bash
set -eo pipefail

# ==============================================================================
# Neovim & LaTeX Environment Automated Setup Script
# Seamlessly bootstraps Neovim (NvChad), LaTeX (VimTeX + Skim/Zathura),
# Mason language servers (ltex-ls, pyright, lua-ls, ruff, stylua), and fonts.
# Supports: macOS (Homebrew) and Linux (Debian/Ubuntu, Fedora, Arch)
# ==============================================================================

export NONINTERACTIVE=1
export HOMEBREW_NO_ENV_HINTS=1
export HOMEBREW_NO_INSTALLED_DEPENDENTS_CHECK=1

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

OS_TYPE="$(uname -s)"
NVIM_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"

echo -e "${BLUE}====================================================${NC}"
echo -e "${GREEN}   Neovim & Development Environment Bootstrap      ${NC}"
echo -e "${BLUE}====================================================${NC}"

# Helper to install package only if command is missing
brew_install_if_missing() {
  local cmd="$1"
  local pkg="$2"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    log_info "Installing ${pkg}..."
    brew install "${pkg}"
  else
    log_success "${pkg} (${cmd}) is already installed."
  fi
}

# 1. System Package Management
case "${OS_TYPE}" in
  Darwin)
    log_info "Detected macOS (${OS_TYPE})"

    # Ensure Homebrew is installed
    if ! command -v brew >/dev/null 2>&1; then
      log_warn "Homebrew not found. Installing Homebrew..."
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      if [[ -f "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
      elif [[ -f "/usr/local/bin/brew" ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
      fi
    fi

    log_info "Verifying core CLI dependencies..."
    brew_install_if_missing nvim neovim
    brew_install_if_missing rg ripgrep
    brew_install_if_missing tree-sitter tree-sitter
    brew_install_if_missing node node
    brew_install_if_missing python3 python3
    brew_install_if_missing luarocks luarocks
    brew_install_if_missing git git
    brew_install_if_missing curl curl

    # Check for TeX distribution (latexmk)
    if ! command -v latexmk >/dev/null 2>&1 && [[ ! -f "/Library/TeX/texbin/latexmk" ]]; then
      log_warn "latexmk not detected. Installing BasicTeX (lightweight MacTeX)..."
      brew install --cask basictex || true
      export PATH="/Library/TeX/texbin:$PATH"
    else
      log_success "latexmk is already available."
    fi

    # PDF Viewer (Skim)
    if [[ ! -d "/Applications/Skim.app" ]]; then
      log_info "Installing Skim PDF viewer for live LaTeX SyncTeX preview..."
      brew install --cask skim || true
    else
      log_success "Skim.app is already installed."
    fi

    # Nerd Font for NvChad icons
    if ! brew list --cask | grep -q "font-jetbrains-mono-nerd-font"; then
      log_info "Installing JetBrains Mono Nerd Font for icons..."
      brew install --cask font-jetbrains-mono-nerd-font 2>/dev/null || true
    else
      log_success "JetBrains Mono Nerd Font is already installed."
    fi
    ;;

  Linux)
    log_info "Detected Linux (${OS_TYPE})"

    if command -v apt-get >/dev/null 2>&1; then
      log_info "Debian/Ubuntu detected. Installing dependencies via apt..."
      sudo apt-get update
      sudo apt-get install -y neovim ripgrep latexmk texlive-latex-extra zathura nodejs npm python3 python3-pip luarocks git curl
    elif command -v dnf >/dev/null 2>&1; then
      log_info "Fedora/RHEL detected. Installing dependencies via dnf..."
      sudo dnf install -y neovim ripgrep latexmk texlive-scheme-basic zathura nodejs npm python3 python3-pip git curl
    elif command -v pacman >/dev/null 2>&1; then
      log_info "Arch Linux detected. Installing dependencies via pacman..."
      sudo pacman -S --needed --noconfirm neovim ripgrep texlive-basic texlive-latexextra zathura nodejs npm python git curl
    else
      log_warn "Unrecognized Linux package manager. Please ensure neovim, ripgrep, latexmk, and node are installed."
    fi
    ;;

  *)
    log_error "Unsupported operating system: ${OS_TYPE}"
    exit 1
    ;;
esac

# 2. Ensure TeX bin is in PATH for current session if on macOS
if [[ -d "/Library/TeX/texbin" ]] && [[ ":$PATH:" != *":/Library/TeX/texbin:"* ]]; then
  export PATH="/Library/TeX/texbin:$PATH"
fi

# 3. Create persistent dictionary directory
mkdir -p "${NVIM_CONFIG_DIR}/ltex"

# 4. Bootstrap Neovim Plugins via Lazy
log_info "Bootstrapping Neovim plugins via Lazy.nvim..."
nvim --headless -c "Lazy! sync" -c "sleep 5" -c "qa"

# 5. Install Language Servers & Tools via Mason
log_info "Installing LSP servers, linters, and formatters via Mason..."
nvim --headless -c "MasonInstall ltex-ls pyright lua-language-server ruff stylua" -c "sleep 12" -c "qa"

# 6. Update Treesitter Parsers
log_info "Compiling Tree-sitter parsers..."
nvim --headless -c "TSUpdate" -c "sleep 5" -c "qa"

# 7. Verification Health Check
log_info "Running verification check on Neovim..."
if nvim --headless -c "checkhealth vim.lsp" -c "qa" 2>/dev/null; then
  log_success "LSP environment passed health check!"
else
  log_warn "Checkhealth finished with notices. Run ':checkhealth' inside Neovim to inspect details."
fi

echo -e "${BLUE}====================================================${NC}"
echo -e "${GREEN}   Setup Complete! Your Neovim environment is ready.${NC}"
echo -e "${BLUE}====================================================${NC}"
echo ""
echo "Next steps:"
echo "  1. Open Neovim: nvim"
echo "  2. If using macOS with Skim:"
echo "     Open Skim -> Preferences -> Sync -> Check 'Check for file changes'"
echo "     Preset: Custom, Command: /Applications/Ghostty.app/Contents/MacOS/ghostty (or your terminal), Arguments: -e nvim --remote-silent +%line \"%file\""
echo ""
