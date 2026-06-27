# Porting these dotfiles to Windows

There are two very different "Windows" targets. Pick based on what you actually
want to run.

| Tool | WSL (Linux on Windows) | Native Windows |
|---|---|---|
| zsh / bash / Oh My Zsh | ✅ works as-is | ❌ no zsh; use Git Bash or WSL |
| tmux | ✅ works as-is | ❌ (no native tmux) |
| Neovim / vim | ✅ | ✅ (`~/.vimrc` → `$HOME\_vimrc`; nvim → `%LOCALAPPDATA%\nvim`) |
| Alacritty | ✅ | ✅ **native** (`%APPDATA%\alacritty\alacritty.toml`) |
| Git | ✅ | ✅ (`%USERPROFILE%\.gitconfig`) |
| gdb, btop, htop, niri, GTK | ✅ (gdb/btop/htop) | ❌ Linux-only |

**Recommendation:** run your shell environment inside **WSL2**. It gives you a
real Linux home where `install.sh` works unchanged, while letting you keep using
Windows apps. Use native Windows config only for GUI apps you run outside WSL
(Alacritty, Neovim, Git for Windows).

---

## Option A — WSL2 (recommended, near-zero changes)

```powershell
# In an elevated PowerShell:
wsl --install            # installs WSL2 + Ubuntu by default
```

Then inside the WSL shell, treat it like any Linux box:

```bash
sudo apt update && sudo apt install -y zsh tmux git neovim gdb btop htop curl
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# install the zsh plugins (see README "Prerequisites" one-liner), then:
git clone <your-repo-url> ~/Documents/dotfiles
cd ~/Documents/dotfiles && ./install.sh
chsh -s "$(which zsh)"    # make zsh your default WSL shell
```

Everything (zsh, tmux, p10k, nvim, gdb) behaves exactly as on Arch. The
`linux-desktop/` configs (niri, GTK) are pointless under WSL and are skipped
automatically.

**Fonts:** install the JetBrainsMono Nerd Font on the *Windows* side and select
it in your terminal (Windows Terminal / Alacritty), not inside WSL.

---

## Option B — Native Windows (GUI apps only)

Symlinks aren't ergonomic on Windows, so **copy** the files instead. Paths use
environment variables that resolve in PowerShell:

```powershell
# Alacritty
mkdir "$env:APPDATA\alacritty" -Force
Copy-Item terminal\alacritty\alacritty.toml "$env:APPDATA\alacritty\alacritty.toml"

# Git
Copy-Item git\.gitconfig "$env:USERPROFILE\.gitconfig"

# Neovim
mkdir "$env:LOCALAPPDATA\nvim" -Force
Copy-Item -Recurse editors\nvim\* "$env:LOCALAPPDATA\nvim\"

# vim (note the underscore filename on Windows)
Copy-Item editors\vim\.vimrc "$env:USERPROFILE\_vimrc"
```

Notes for native Windows:
- The Alacritty font family (`JetBrainsMono Nerd Font`) must be installed in
  Windows. The rest of `alacritty.toml` is cross-platform.
- For a Unix-like shell without WSL, **Git Bash** (ships with Git for Windows)
  reads `~/.bashrc`, so `shell/bash/.bashrc` mostly works there — but drop the
  Linux-specific PATH/cargo lines if Rust isn't installed the same way.
- Neovim plugins (lazy.nvim) will re-bootstrap on first launch; let it finish.

---

## Keeping things in sync

Because the repo is the source of truth, the workflow is the same everywhere:

1. Edit a file in `~/Documents/dotfiles`.
2. `git commit && git push`.
3. On the other machine: `git pull` (+ re-run `install.sh` if you added new files).
