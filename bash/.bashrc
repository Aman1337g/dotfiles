# ==========================================
# ~/.bashrc - Interactive Shell
# ==========================================

# CI/CD Guard: Exit immediately if not running interactively
[[ $- != *i* ]] && return

# Source global definitions
[ -f /etc/bashrc ] && . /etc/bashrc

# Enable programmable completions
for completion in /usr/share/bash-completion/bash_completion /etc/bash_completion; do
  [ -f "$completion" ] && . "$completion" && break
done

# --- History Management ---
export HISTCONTROL=ignoreboth:erasedups
export HISTSIZE=10000
export HISTFILESIZE=50000
shopt -s histappend
PROMPT_COMMAND='history -a'

# --- Shell Options & Keybindings ---
shopt -s checkwinsize cdspell extglob
set -o vi
bind "set bell-style none"

# Safely bind custom scripts
[ -f "$HOME/scripts/motivation" ] && bind '"\em":"'$HOME'/scripts/motivation\n"'
[ -f "$HOME/scripts/define_word" ] && bind '"\ee":"'$HOME'/scripts/define_word\n"'

# --- Tool Initialization (Silent fallback if missing) ---
# NVM
export NVM_DIR="$XDG_CONFIG_HOME/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

# Pyenv
command -v pyenv >/dev/null && eval "$(pyenv init -)"

# UI & Prompt
[ -f "$HOME/.fzf.bash" ] && source "$HOME/.fzf.bash"
command -v starship >/dev/null && eval "$(starship init bash)"
if command -v zoxide >/dev/null; then
  eval "$(zoxide init --cmd cd bash)"
  bind -x '"\C-f": cdi' 2>/dev/null
fi

# Yazi integration (POSIX safe mktemp)
z() {
  local tmp cwd
  tmp="$(mktemp -t yazi-cwd.XXXXXX)" || return 1
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    cd -- "$cwd" || return 1
  fi
  rm -f -- "$tmp"
}

# Load aliases
[ -f "$HOME/.bash_aliases" ] && . "$HOME/.bash_aliases"
