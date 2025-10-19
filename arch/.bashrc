#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

PROMPT_DIRTRIM=2
PS1='[\u@\h \w]\$ '

force_color_prompt=yes
color_prompt=yes
shopt -s histappend
HISTCONTROL=ignoreboth

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias vi='nvim'
alias vim='nvim'
alias ff="fzf --preview 'bat --style=numbers --color=always {}'"
alias tree='eza --tree --long --icons --git'
alias lss='eza -lh --group-directories-first --icons=auto'

open() {
	xdg-open "$@" > /dev/null 2>&1 &
}

export EDITOR="nvim"
export HYPRSHOT_DIR="$HOME/screenshots"

