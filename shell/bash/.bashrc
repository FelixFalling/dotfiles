#
# ~/.bashrc
#

export EDITOR='nvim'
export VISUAL='nvim'

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

stty -ixon

parse_git_branch() {
     git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/[\1]/'
}

YELLOW='\033[38;5;227m'
SEAFOAM='\033[38;5;84m'
LIGHTBLUE='\033[38;5;123m'
SALMON='\033[38;5;209m'
NONE='\033[0m'

export PS1="${YELLOW}[\h]${SEAFOAM}[\u]${LIGHTBLUE}[\w]${SALMON}\$(parse_git_branch)${NONE}\n: "

if [ -e ~/.bash_aliases ]; then
    source ~/.bash_aliases
fi

#Newer python versions
# export PATH=/usr/local/bin:$PATH
#export PATH=$HOME/usr/bin:$PATH

export PATH=$HOME/usr/bin:/usr/local/bin:$PATH
export PYTHON_ROOT=$HOME/usr
export PYTHON_VERSION=3.13
export LD_LIBRARY_PATH=$HOME/usr/lib:$LD_LIBRARY_PATH

alias neofetch='fastfetch'
alias nano='nvim'
alias vim='nvim'

alias psu-vpn="sudo openconnect vpn.pdx.edu --useragent 'AnyConnect' --no-external-auth"
. "$HOME/.cargo/env"
