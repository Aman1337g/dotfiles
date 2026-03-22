# Safely load .profile variables ONLY once to prevent infinite PATH growth
if [ -z "$PROFILE_LOADED" ] && [ -f "$HOME/.profile" ]; then
  export PROFILE_LOADED=1
  source "$HOME/.profile"
fi

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

# NVM (Added a fallback in case XDG_CONFIG_HOME is empty on a fresh OS)
export NVM_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

# Pyenv (Safe Initialization & Idempotent PATH for Windows Git Bash)
if [ -d "$HOME/.pyenv/bin" ]; then
  # 🛡️ Only add to PATH if it is not already there
  if [[ ":$PATH:" != *":$HOME/.pyenv/bin:"* ]]; then
    export PATH="$HOME/.pyenv/bin:$PATH"
  fi
  # Only init if pyenv is a real executable, not a broken Windows symlink
  if command -v pyenv >/dev/null 2>&1 && [ -x "$HOME/.pyenv/libexec/pyenv" ]; then
    eval "$(pyenv init -)"
  fi
fi

# UI & Prompt

# ==========================================
# 🔍 FZF KEYBINDINGS (The Ctrl+R Upgrade)
# ==========================================
if command -v fzf >/dev/null 2>&1; then
  # Debian/Ubuntu apt location
  if [ -f /usr/share/doc/fzf/examples/key-bindings.bash ]; then
    source /usr/share/doc/fzf/examples/key-bindings.bash
  # Homebrew location
  elif [ -f "$(brew --prefix 2>/dev/null)/opt/fzf/shell/key-bindings.bash" ]; then
    source "$(brew --prefix 2>/dev/null)/opt/fzf/shell/key-bindings.bash"
  # Standard git clone location
  elif [ -f ~/.fzf.bash ]; then
    source ~/.fzf.bash
  fi
fi
command -v starship >/dev/null && eval "$(starship init bash)"

# Mise Integration (Dynamically manages toolchains)
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate bash)"
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

# Zoxide
if command -v zoxide >/dev/null; then
  eval "$(zoxide init --cmd cd bash)"
  bind -x '"\C-f": cdi' 2>/dev/null
fi
