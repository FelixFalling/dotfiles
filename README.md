# dotfiles

Personal configuration for shells, terminal, editors, and dev tooling — kept in
one place so it's documented, portable, and easy to redeploy on a new machine.

- **Edit configs here**, not in `$HOME`. `install.sh` symlinks these files into
  place, so the repo is the single source of truth.
- Designed to port cleanly to **Linux**, **macOS**, and **Windows (WSL)**. See
  [`docs/WINDOWS.md`](docs/WINDOWS.md) for the Windows story.

---

## Quick start (new machine)

```bash
git clone <your-repo-url> ~/Documents/dotfiles
cd ~/Documents/dotfiles

# Install prerequisites first (see "Prerequisites" below), then:
./install.sh            # symlink core + (on Linux) desktop configs
./install.sh --nvim     # ...also take over ~/.config/nvim
./install.sh --dry-run  # preview without changing anything

exec zsh                # reload your shell
```

Existing files are moved to `.backups/<timestamp>/` before any symlink is made.
To undo everything and restore those backups:

```bash
./uninstall.sh
```

---

## What's in here

```
dotfiles/
├── install.sh / uninstall.sh   # symlink the configs into place (with backups)
├── lib/links.sh                # the file->destination map both scripts share
├── shell/
│   ├── zsh/    .zshrc .zshenv .p10k.zsh
│   └── bash/   .bashrc .bash_profile .bash_logout .profile
├── tmux/       .tmux.conf
├── editors/
│   ├── vim/    .vimrc
│   └── nvim/   NvChad-based config (init.lua + lua/…)
├── terminal/
│   ├── alacritty/         alacritty.toml
│   └── cool-retro-term/   cool-retro-term.conf
├── git/        .gitconfig  gitignore_global
├── debug/      .gdbinit
├── cli-tools/  btop/  htop/
├── linux-desktop/   gtk/  niri/        # Linux-only; skipped off-Linux
├── scripts/    bashkeys.c  fix-razer-middle-click.sh
└── docs/       WINDOWS.md
```

### File-by-file

| Config | Installs to | What it does | Portable? |
|---|---|---|---|
| `shell/zsh/.zshrc` | `~/.zshrc` | Interactive zsh: Oh My Zsh, plugins, aliases, history | Linux/macOS/WSL |
| `shell/zsh/.zshenv` | `~/.zshenv` | Env for **all** zsh invocations; editor + cargo | Linux/macOS/WSL |
| `shell/zsh/.p10k.zsh` | `~/.p10k.zsh` | Powerlevel10k prompt (only active with the p10k theme) | Linux/macOS/WSL |
| `shell/bash/.bashrc` | `~/.bashrc` | Bash fallback prompt + aliases | Linux/macOS/WSL |
| `shell/bash/.bash_profile` `.profile` | `~/…` | Login-shell glue (source bashrc, cargo) | Linux/macOS/WSL |
| `tmux/.tmux.conf` | `~/.tmux.conf` | tmux: red/yellow theme, vim nav, sane defaults | Linux/macOS/WSL |
| `editors/vim/.vimrc` | `~/.vimrc` | Minimal vim (numbers, 4-wide tabs, centered scroll) | Anywhere vim runs |
| `editors/nvim/` | `~/.config/nvim/` | Neovim (NvChad v2.5, catppuccin) — **opt-in** | Linux/macOS/WSL |
| `terminal/alacritty/alacritty.toml` | `~/.config/alacritty/…` | Alacritty: JetBrainsMono Nerd Font, padding | **incl. native Windows** |
| `terminal/cool-retro-term/…` | `~/.config/cool-retro-term/…` | cool-retro-term UI state | Linux/macOS |
| `git/.gitconfig` | `~/.gitconfig` | Git identity + `editor = nvim` | Anywhere |
| `git/gitignore_global` | `~/.config/git/ignore` | Global gitignore | Anywhere |
| `debug/.gdbinit` | `~/.gdbinit` | GDB + splitmind layout (see gotcha below) | Linux/WSL |
| `cli-tools/btop/btop.conf` | `~/.config/btop/…` | btop resource monitor | Linux/macOS/WSL |
| `cli-tools/htop/htoprc` | `~/.config/htop/…` | htop meters/columns | Linux/macOS/WSL |
| `linux-desktop/gtk/.gtkrc-2.0` | `~/.gtkrc-2.0` | GTK2 theme (Breeze-Dark) | Linux only |
| `linux-desktop/niri/config.kdl` | `~/.config/niri/…` | niri Wayland compositor | Linux only |
| `scripts/bashkeys.c` | (build manually) | Tiny readline cheat-sheet printer | Linux/macOS/WSL |
| `scripts/fix-razer-middle-click.sh` | (run manually, sudo) | Patch OpenRazer for Naga Trinity middle-click | Linux only |

---

## Prerequisites

The configs assume these are installed. On a fresh machine, set them up *before*
running `install.sh` (or the shell will warn about missing plugins/tools).

**Shell stack**
- [Oh My Zsh](https://ohmyz.sh/) at `~/.oh-my-zsh`
- Custom zsh plugins into `~/.oh-my-zsh/custom/plugins/`:
  [`zsh-autosuggestions`](https://github.com/zsh-users/zsh-autosuggestions),
  [`zsh-syntax-highlighting`](https://github.com/zsh-users/zsh-syntax-highlighting),
  [`zsh-completions`](https://github.com/zsh-users/zsh-completions),
  [`zsh-history-substring-search`](https://github.com/zsh-users/zsh-history-substring-search)
- (Optional prompt) [Powerlevel10k](https://github.com/romkatv/powerlevel10k) into
  `~/.oh-my-zsh/custom/themes/powerlevel10k`

**Fonts**
- A **JetBrainsMono Nerd Font** (Alacritty + p10k icons). Grab from
  [nerdfonts.com](https://www.nerdfonts.com/).

**CLI tools referenced by the configs** (install what you use)
- `nvim`, `tmux`, `git`, `gdb`, `btop`, `htop`
- `thefuck` (zsh inits it *only if present* — safe to skip)
- `fastfetch` (the bash `neofetch` alias points at it)

One-liner to fetch the zsh plugins:

```bash
ZC="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
for p in zsh-autosuggestions zsh-syntax-highlighting zsh-completions zsh-history-substring-search; do
  git clone --depth=1 "https://github.com/zsh-users/$p" "$ZC/plugins/$p"
done
git clone --depth=1 https://github.com/romkatv/powerlevel10k "$ZC/themes/powerlevel10k"
```

---

## Gotchas & notes

- **Prompt theme.** `.zshrc` currently uses the lightweight **`aussiegeek`** theme.
  A full **Powerlevel10k** config ships in `.p10k.zsh` but is dormant. To switch,
  flip the two `ZSH_THEME=` lines near the top of `.zshrc` (documented inline).

- **`.gdbinit` has a hard-coded path.** It sources
  `~/Downloads/splitmind/gdbinit.py`. On a new machine, install
  [splitmind](https://github.com/jerdna-regeiz/splitmind) (and a GDB enhancer like
  GEF/pwndbg) or that line will error. Consider relocating splitmind out of
  `~/Downloads`.

- **Neovim is NvChad-based** (`branch v2.5`) and is normally its own git repo.
  It's `--nvim`-opt-in so `install.sh` doesn't clobber a live NvChad checkout.
  Your edits live in `lua/chadrc.lua`, `lua/mappings.lua`, `lua/options.lua`,
  `lua/custom/`, and `lua/configs/`. `lazy-lock.json` pins plugin versions.

- **niri** (`linux-desktop/niri/`) is also typically self-managed; included here as
  a backup. Linux/Wayland only — not relevant to macOS or Windows.

- **`bashkeys`** is a compiled helper the zsh alias expects at `~/.local/bin/bashkeys`:
  ```bash
  cc scripts/bashkeys.c -o ~/.local/bin/bashkeys
  ```

- **Backups** from `install.sh` land in `.backups/` (git-ignored). `uninstall.sh`
  restores the most recent one.

See [`docs/WINDOWS.md`](docs/WINDOWS.md) for porting to Windows / WSL.
