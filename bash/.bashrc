set -o vi
export GTK_A11Y=none
export GTK_THEME=Nordic-darker
bind '"\em":"/home/aman/scripts/motivation\n"'
bind '"\eD":"/home/aman/scripts/define_word\n"'

# Set terminal to support 256 colors
export TERM="xterm-256color"

# Exit if not running interactively
[[ $- != *i* ]] && return

# Source global definitions, if available
[ -f /etc/bashrc ] && . /etc/bashrc

# Enable programmable completion features, if available
for completion in /usr/share/bash-completion/bash_completion /etc/bash_completion; do
  [ -f "$completion" ] && . "$completion" && break
done

# Disable the terminal bell
bind "set bell-style none"

# Set history control: ignore duplicates and commands starting with space
export HISTCONTROL=ignoreboth

# Set history sizes
export HISTSIZE=10000
export HISTFILESIZE=500

# Append to the history file, don't overwrite it
shopt -s histappend
PROMPT_COMMAND='history -a'

# Update LINES and COLUMNS after each command if window size has changed
shopt -s checkwinsize

# Enable command auto-correction for 'cd'
shopt -s cdspell

# Enable extended pattern matching features
shopt -s extglob

# Set up XDG base directories
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"

# Set default editor
export EDITOR=nvim
export VISUAL=nvim

# Configure less to be more friendly for non-text input files
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Set terminal title for supported terminals
case ${TERM} in
xterm* | rxvt* | Eterm* | aterm | kterm | gnome* | alacritty | st | konsole* | kitty)
  PROMPT_COMMAND+='; echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\007"'
  ;;
screen*)
  PROMPT_COMMAND+='; echo -ne "\033_${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\033\\"'
  ;;
esac

# Define aliases
alias ls='eza -al --color=always --group-directories-first'
alias la='eza -a --color=always --group-directories-first'
alias ll='eza -l --color=always --group-directories-first'
alias lt='eza -aT --color=always --group-directories-first'
alias l.='eza -a | grep "^\."'
alias l..='eza -al --color=always --group-directories-first ../../'
alias l...='eza -al --color=always --group-directories-first ../../../'
alias grep='grep --color=auto'
alias alert='notify-send --urgency=low -i "$( [ $? = 0 ] && echo terminal || echo error )" "$(history | tail -n1 | sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'' )"'

# Load custom aliases if available
[ -f ~/.bash_aliases ] && . ~/.bash_aliases

# Configure nvm (Node Version Manager)
export NVM_DIR="$XDG_CONFIG_HOME/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

# Update PATH for custom scripts and applications
export PATH="$HOME/scripts:/opt/nvim-linux64/bin:$HOME/.local/share/gnome-shell/extensions/ddterm@amezin.github.com/bin:$PATH"

# Set up fzf key bindings and fuzzy completion
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# Initialize starship prompt
eval "$(starship init bash)"

# Initialize zoxide for enhanced 'cd' command
eval "$(zoxide init --cmd cd bash)"
bind -x '"\C-f": cdi'

# Initialize cargo environment
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# Define 'z' function for yazi integration
z() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(<"$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}
