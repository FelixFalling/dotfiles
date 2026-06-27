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

# Prompt theme. Currently using the lightweight "aussiegeek" theme.
# To switch to Powerlevel10k instead, comment the line below, uncomment the
# powerlevel10k line, and make sure ~/.p10k.zsh exists (run `p10k configure`).
ZSH_THEME="aussiegeek"
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

# History quality-of-life (the OMZ `history` plugin sets HISTFILE/SIZE; these
# refine the behavior).
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_ALL_DUPS   # drop older duplicate of a repeated command
setopt HIST_REDUCE_BLANKS     # trim superfluous whitespace before saving
setopt HIST_VERIFY            # expand !! etc. onto the line instead of running blind
setopt SHARE_HISTORY          # share history live across open terminals

# Powerlevel10k prompt config (only takes effect with the p10k theme above).
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


###############################################################################
# 5. ALIASES
###############################################################################
# Use Neovim everywhere.
alias vim='nvim'
alias vi='nvim'
alias view='nvim -R'
alias vimdiff='nvim -d'

# Bash/readline keybinding cheat sheet (compile scripts/bashkeys.c -> ~/.local/bin/bashkeys).
alias bashkeys="$HOME/.local/bin/bashkeys"

# Connect to the PSU VPN.
alias psu-vpn="sudo openconnect vpn.pdx.edu --useragent 'AnyConnect' --no-external-auth"


###############################################################################
# 6. EXTERNAL TOOL INIT
###############################################################################
# `thefuck` corrects the previous command (run: fuck). Guarded so this file
# still works on machines where thefuck isn't installed.
command -v thefuck >/dev/null 2>&1 && eval "$(thefuck --alias)"
