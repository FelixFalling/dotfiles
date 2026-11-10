################################################################################
# ~/.zshrc — interactive zsh configuration (Oh My Zsh)
#
# Maintained in: ~/Documents/dotfiles/shell/zsh/.zshrc (symlinked to ~/.zshrc)
# Loaded for:    interactive shells only. Env that must exist for ALL shells
#                (scripts, ssh commands) goes in ~/.zshenv instead.
#
# Sections:  1. p10k instant prompt   4. User environment
#            2. Oh My Zsh core        5. Aliases
#            3. Plugins               6. External tool init
################################################################################


###############################################################################
# 1. POWERLEVEL10K INSTANT PROMPT
###############################################################################
# Only has an effect when ZSH_THEME is "powerlevel10k/powerlevel10k" (see below).
# Must stay near the top. Anything that prints to the console or needs input
# (password / [y/n] prompts) must go ABOVE this block.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


###############################################################################
# 2. OH MY ZSH CORE
###############################################################################
export ZSH="$HOME/.oh-my-zsh"

# Prompt theme. Empty = no OMZ theme; the prompt is the one ported from
# ~/.bashrc, defined right after oh-my-zsh.sh is sourced below.
# To go back to aussiegeek, set ZSH_THEME="aussiegeek" and delete the
# "Prompt (ported from ~/.bashrc)" block. For Powerlevel10k, do the same with the
# powerlevel10k line and make sure ~/.p10k.zsh exists (run `p10k configure`).
ZSH_THEME=""
# ZSH_THEME="aussiegeek"
# ZSH_THEME="powerlevel10k/powerlevel10k"


###############################################################################
# 3. PLUGINS
###############################################################################
# Order matters for the last two: zsh-syntax-highlighting must come before
# zsh-history-substring-search, and both should be near the end.
# Custom plugins (the zsh-* ones) live in ~/.oh-my-zsh/custom/plugins/ — install
# them there on a new machine or the shell will warn about missing plugins.
plugins=(
  git                           # git aliases + branch info
  sudo                          # press ESC twice to prefix the last command with sudo
  web-search                    # `google ...`, `ddg ...` from the shell
  copybuffer                    # Ctrl-O copies the current command line to the clipboard
  dirhistory                    # Alt+Left/Right to walk directory history
  history                       # `h`, `hs` history helpers
  jsontools                     # pp_json / is_json / urlencode helpers
  zsh-completions               # extra completion definitions
  zsh-autosuggestions           # fish-style "type-ahead" suggestions from history
  zsh-syntax-highlighting       # colorize the command line as you type (load 2nd-to-last)
  zsh-history-substring-search  # type a prefix + Up/Down to search history (load LAST)
)

source $ZSH/oh-my-zsh.sh

# --- Prompt (ported from ~/.bashrc) ----------------------------------------------------
#   [host][user][~/current/dir][branch]
#   : _
# Same 256-color codes as the bash PS1: 227 yellow, 84 seafoam, 123 light blue, 209 salmon.
# %m = \h, %n = \u, %~ = \w. Unlike the bash version, zsh's %F{} escapes are zero-width
# automatically, so long command lines wrap correctly.
_prompt_git_branch() {
  local ref
  ref=$(git symbolic-ref --short -q HEAD 2>/dev/null) ||   # on a branch
    ref=$(git rev-parse --short HEAD 2>/dev/null) ||       # detached HEAD: short sha
    return 0                                               # not a git repo
  print -rn -- "[${ref//\%/%%}]"   # escape % so a branch name can't inject prompt codes
}
PROMPT='%F{227}[%m]%F{84}[%n]%F{123}[%~]%F{209}$(_prompt_git_branch)%f'$'\n'': '

# aussiegeek marks a clean git repo with ✔ and a dirty one with ✗, but 0xProto Nerd Font
# has neither, so the terminal borrowed them from DejaVu Sans Mono in a different shape.
# These are the Nerd Font's own check and X (nf-fa-check, nf-fa-xmark), drawn in style.
ZSH_THEME_GIT_PROMPT_CLEAN=$''
ZSH_THEME_GIT_PROMPT_DIRTY=$''


###############################################################################
# 4. USER ENVIRONMENT
###############################################################################
# Prefer nvim locally, but fall back to vim over SSH (remote box may lack nvim).
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# Personal bin on PATH.
export PATH="$HOME/.local/bin:$PATH"

# Turn off XON/XOFF flow control (same as `stty -ixon` in ~/.bashrc), so Ctrl-S no longer
# freezes the terminal. That frees Ctrl-S for zsh's forward history search.
[[ -t 0 ]] && stty -ixon

# History quality-of-life (the OMZ `history` plugin sets HISTFILE/SIZE; these
# refine the behavior).
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_ALL_DUPS   # drop older duplicate of a repeated command
setopt HIST_REDUCE_BLANKS     # trim superfluous whitespace before saving
setopt HIST_VERIFY            # expand !! etc. onto the line instead of running blind
setopt SHARE_HISTORY          # share history live across open terminals
setopt HIST_IGNORE_SPACE      # prefix a command with a space to keep it out of history

# --- what never reaches history (and so never reaches zsh-autosuggestions) --------------
# zshaddhistory runs BEFORE the command does, so none of this can judge exit status - it
# judges the TEXT of the line. Returning non-zero drops the line.
#
# Your own private patterns live in ~/.config/zsh/history-ignore, deliberately OUTSIDE the
# dotfiles git repo so the patterns themselves are never committed or pushed. One
# case-insensitive substring per line, # for comments. Reload with: histignore-reload
_HIST_DENY=()
_hist_load_deny() {
  emulate -L zsh
  local f=$HOME/.config/zsh/history-ignore l
  _HIST_DENY=()
  [[ -r $f ]] || return 0
  while IFS= read -r l; do
    [[ $l == \#* || -z ${l//[[:space:]]/} ]] && continue
    _HIST_DENY+=("$l")
  done < $f
}
_hist_load_deny
alias histignore-reload='_hist_load_deny; _hist_load_words; print "reloaded ${#_HIST_DENY} pattern(s)"'

# Whole-word blocklist (~/.config/zsh/history-words), matched with WORD BOUNDARIES so
# "$SHELL", "shellcheck", "assets", "class" and "assert" survive while the actual words do
# not. Also outside the dotfiles repo, so the list itself is never committed.
_HIST_WORD_RE=''
_hist_load_words() {
  emulate -L zsh
  local f=$HOME/.config/zsh/history-words l
  local -a w
  _HIST_WORD_RE=''
  [[ -r $f ]] || return 0
  while IFS= read -r l; do
    [[ $l == \#* || -z ${l//[[:space:]]/} ]] && continue
    w+=("${l:l}")
  done < $f
  (( $#w )) || return 0
  _HIST_WORD_RE="(^|[^a-z0-9])(${(j:|:)w})(s|es|ed|ing|er|ers|in|y)?([^a-z0-9]|\$)"
}
_hist_load_words

# Clutter and one-offs. These are about usefulness, not privacy: bare `ls`/`cd` dominate
# autosuggestions and are never worth recalling, and a 200-character paste is a one-off.
# Destructive commands are here for a different reason - keeping them OUT means a stray Tab
# can never autocomplete you into re-running `rm -rf`. Plain `rm file.txt` is unaffected.
_HIST_NOISE_RE='^[[:space:]]*((pwd|clear|exit|logout|reset|whoami|history)|(ls|ll|la|lsd|eza)([[:space:]]+-[a-zA-Z]+)*|cd([[:space:]]+(\.\.|-|~|/))?|cat)[[:space:]]*$'
_HIST_DESTRUCTIVE_RE='(rm[[:space:]]+(-[a-za-z]*[rf][a-za-z]*[[:space:]]+)+|[[:space:]]dd[[:space:]]+if=|^dd[[:space:]]+if=|mkfs|shred[[:space:]]|>[[:space:]]*/dev/(sd|nvme))'
# Only URLs handed to a BROWSER. `curl https://...` and `git clone https://...` are work,
# not browsing, and stay.
_HIST_URL_RE='(xdg-open|firefox|chromium|google-chrome|brave|browser)[[:space:]]+[^[:space:]]*https?://'
# Email addresses - but ssh/scp/rsync user@host is not an email, and blocking those would
# cost you the commands you use most.
_HIST_EMAIL_RE='[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}'
_HIST_REMOTE_RE='(^|[[:space:]])(ssh|scp|sftp|rsync|mosh|tailscale)([[:space:]]|$)'
_HIST_MAXLEN=200

# Credentials, matched by SHAPE rather than by a wordlist, so "tokenizer.py" and "token
# bucket rate limiter" survive while GITHUB_TOKEN=ghp_... does not.
_HIST_SECRET_RE='(password|passwd|passphrase|secret|api[_-]?key|apikey|credential|authkey|bearer |begin [a-z ]*private key|private[_-]key|[a-z0-9_-]*token[a-z0-9_-]*[[:space:]]*[=:]|--token|gh[pousr]_[a-za-z0-9]{16,}|github_pat_[a-za-z0-9_]{20,}|sk-[a-za-z0-9]{20,}|xox[baprs]-[a-za-z0-9-]{10,}|akia[0-9a-z]{16}|tskey-[a-za-z0-9-]{10,}|glpat-[a-za-z0-9_-]{15,}|aiza[0-9a-za-z_-]{30,})'
# SSN, card-length digit runs, phone numbers, and base64/hex blobs long enough to be a key.
_HIST_PII_RE='([0-9]{3}-[0-9]{2}-[0-9]{4}|[0-9]{13,19}|\+?[0-9]{3}[-. ][0-9]{3}[-. ][0-9]{4}|[A-Za-z0-9+/]{40,}={0,2}|[0-9a-f]{40,})'

zshaddhistory() {
  emulate -L zsh
  local line=${1%%$'\n'} low w p
  local -a words
  low=${line:l}

  # 1. clutter, one-offs, destructive commands, browser URLs, email addresses
  (( ${#line} > _HIST_MAXLEN )) && return 1
  [[ $line =~ $_HIST_NOISE_RE ]] && return 1
  [[ $low  =~ $_HIST_DESTRUCTIVE_RE ]] && return 1
  [[ $low  =~ $_HIST_URL_RE ]] && return 1
  [[ ! $low =~ $_HIST_REMOTE_RE && $low =~ $_HIST_EMAIL_RE ]] && return 1

  # 2. credentials and PII
  [[ $low =~ $_HIST_SECRET_RE ]] && return 1
  [[ $line =~ $_HIST_PII_RE ]] && return 1

  # 3. your own private patterns
  for p in $_HIST_DENY; do
    [[ $low == *${(L)p}* ]] && return 1
  done

  # 4. whole words you have blocklisted
  [[ -n $_HIST_WORD_RE && $low =~ $_HIST_WORD_RE ]] && return 1

  # 5. typos: does the command actually exist? Step past wrappers first, so
  #    "sudo gti push" is judged on "gti" rather than on "sudo", which always exists.
  words=(${(z)line})
  while (( $#words )); do
    w=$words[1]
    case $w in
      *=*|sudo|doas|command|builtin|nohup|time|env|setsid|exec|nice|ionice|-*) shift words ;;
      *) break ;;
    esac
  done
  (( $#words )) || return 0
  w=$words[1]
  if [[ $w == */* ]]; then          # a path - let the filesystem decide
    [[ -x $w || -d $w ]] || return 1
    return 0
  fi
  whence -w -- $w >/dev/null 2>&1 || return 1
  return 0
}

# Powerlevel10k prompt config (only takes effect with the p10k theme above).
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


###############################################################################
# 5. ALIASES
###############################################################################
# nvim runs Neovim; vim/vi runs classic Vim with ~/.vimrc.
alias view='nvim -R'
alias vimdiff='nvim -d'
alias nano='nvim'

alias neofetch='fastfetch'

# Bash/readline keybinding cheat sheet (compile scripts/bashkeys.c -> ~/.local/bin/bashkeys).
alias bashkeys="$HOME/.local/bin/bashkeys"

# Connect to the PSU VPN.
alias psu-vpn="sudo openconnect vpn.pdx.edu --useragent 'AnyConnect' --no-external-auth"


###############################################################################
# 6. EXTERNAL TOOL INIT
###############################################################################
# Open or reconnect to a named tmux session: t [name] (default: main).
# Within tmux, switch sessions instead of nesting another tmux client.
t() {
  local session_name=${1:-main}
  if [[ -n $TMUX ]]; then
    tmux has-session -t "=$session_name" 2>/dev/null ||
      tmux new-session -d -s "$session_name" || return
    tmux switch-client -t "=$session_name"
  else
    tmux new-session -A -s "$session_name"
  fi
}

# `thefuck` corrects the previous command (run: fuck). Guarded so this file
# still works on machines where thefuck isn't installed.
command -v thefuck >/dev/null 2>&1 && eval "$(thefuck --alias)"
export OLLAMA_API_BASE=http://127.0.0.1:11434

###############################################################################
# `game ./thing.exe [args]` runs a Windows exe with GE-Proton via umu-launcher,
# no Steam needed. Each game gets its own prefix in ~/.proton/<game folder>;
# override with GAME_PREFIX=name. Runs from the exe's folder.
game() {
  [[ -f "$1" ]] || { echo "usage: game <file.exe> [args]" >&2; return 1; }
  local exe="$(realpath "$1")"; shift
  local dir="$(dirname "$exe")"
  local prefix="$HOME/.proton/${GAME_PREFIX:-$(basename "$dir")}"
  mkdir -p "$prefix"
  (cd "$dir" && WINEPREFIX="$prefix" PROTONPATH="${PROTONPATH:-GE-Proton}" umu-run "$exe" "$@")
}


# Added by Antigravity CLI installer
export PATH="$HOME/.local/bin:$PATH"

# Steam Remote Play: the firewall keeps its ports closed. Open them on the home network for a session.
remoteplay-on() {
  sudo ufw allow from 192.168.0.0/16 to any port 27031:27036 proto udp
  sudo ufw allow from 192.168.0.0/16 to any port 27036:27037 proto tcp
}
remoteplay-off() {
  sudo ufw delete allow from 192.168.0.0/16 to any port 27031:27036 proto udp
  sudo ufw delete allow from 192.168.0.0/16 to any port 27036:27037 proto tcp
}

# Added by flyctl installer
export FLYCTL_INSTALL="$HOME/.fly"
export PATH="$FLYCTL_INSTALL/bin:$PATH"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/felix/.local/share/google-cloud-sdk/path.zsh.inc' ]; then . '/home/felix/.local/share/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/home/felix/.local/share/google-cloud-sdk/completion.zsh.inc' ]; then . '/home/felix/.local/share/google-cloud-sdk/completion.zsh.inc'; fi
