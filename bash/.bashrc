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

# ==========================================
# 1. Shell Options & History
# ==========================================
export HISTCONTROL=ignoreboth:erasedups
export HISTSIZE=10000
export HISTFILESIZE=50000
shopt -s histappend checkwinsize cdspell extglob
PROMPT_COMMAND='history -a'

set -o vi
bind "set bell-style none"

# Safely bind custom scripts
[ -f "$HOME/scripts/motivation" ] && bind '"\em":"'$HOME'/scripts/motivation\n"'
[ -f "$HOME/scripts/define_word" ] && bind '"\ee":"'$HOME'/scripts/define_word\n"'

# ==========================================
# 2. SSH Agent (The Final Fix)
# ==========================================
# Fallback: Get username from system if $USER is unset
_UNAME=${USER:-$(id -un)}

# Use the safe, discovered username for the socket
export SSH_AUTH_SOCK="/tmp/ssh-agent-$_UNAME.sock"

# Start agent only if the socket file is missing
if [ ! -S "$SSH_AUTH_SOCK" ]; then
  # Kill only agents belonging to THIS discovered user
  pkill -u "$_UNAME" ssh-agent >/dev/null 2>&1
  rm -f "$SSH_AUTH_SOCK"
  ssh-agent -a "$SSH_AUTH_SOCK" >/dev/null
fi

# Key Loader Helper
load_ssh_key() {
  local key=$1
  if [ -f "$key" ]; then
    # Check if key is already in agent by fingerprint
    if ! ssh-add -l | grep -q "$(ssh-keygen -lf "$key" | awk '{print $2}')"; then
      ssh-add "$key" 2>/dev/null
    fi
  fi
}

# Load keys into the agent
load_ssh_key ~/.ssh/id_ed25519
load_ssh_key ~/.ssh/wsl_spglobal
load_ssh_key ~/.ssh/id_ed25519_amandev

# ==========================================
# 3. Tool Initialization & Wrappers
# ==========================================

# --- NVM (Added a fallback in case XDG_CONFIG_HOME is empty on a fresh OS) ---
export NVM_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

# --- Pyenv (Safe Initialization & Idempotent PATH for Windows Git Bash) ---
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

# --- FZF Keybindings (The Ctrl+R Upgrade) ---
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

# --- Yazi Integration (POSIX safe mktemp wrapper) ---
z() {
  local tmp cwd
  tmp="$(mktemp -t yazi-cwd.XXXXXX)" || return 1
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    cd -- "$cwd" || return 1
  fi
  rm -f -- "$tmp"
}

# --- Mise Integration (Dynamically manages toolchains) ---
if command -v mise >/dev/null 2>&1 || [ -f "$HOME/.local/bin/mise.exe" ]; then
  # 1. Precise Environment Detection
  if [ -n "$TERMUX_VERSION" ]; then
    export MISE_ENV="termux"
  elif [ -f /.dockerenv ] || [ -f /run/.containerenv ]; then
    export MISE_ENV="container"
  elif grep -qi microsoft /proc/version 2>/dev/null; then
    export MISE_ENV="linux" # Treat WSL exactly like native Linux
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    export MISE_ENV="linux"
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    export MISE_ENV="mac"
  elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    export MISE_ENV="windows"
  fi

  # 2. Activate or Shim Map
  if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    # Native Windows mise.exe uses semicolons, which breaks Git Bash.
    # We bypass 'activate' and manually inject both possible Windows shim locations.
    export PATH="$HOME/AppData/Local/mise/shims:$HOME/.local/share/mise/shims:$PATH"
  else
    # Safe to use standard activation on Unix systems
    eval "$(mise activate bash)"
  fi
fi

# ==========================================
# 4. Aliases (Must be loaded BEFORE Zoxide)
# ==========================================
[ -f "$HOME/.bash_aliases" ] && . "$HOME/.bash_aliases"

# ==========================================
# 5. UI Prompt & Directory Navigation
# ==========================================
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
  # --- WINDOWS GIT BASH (CACHED MODE) ---
  # Kills the 20-second process forking lag by reading from text files
  
  # 1. Starship Cache
  if command -v starship >/dev/null; then
    STARSHIP_CACHE="$HOME/.starship_cache.sh"
    if [ ! -s "$STARSHIP_CACHE" ]; then
      starship init bash > "$STARSHIP_CACHE"
    fi
    source "$STARSHIP_CACHE"
  fi

  # 2. Zoxide Cache (Must be absolutely last)
  if command -v zoxide >/dev/null; then
    ZOXIDE_CACHE="$HOME/.zoxide_cache.sh"
    if [ ! -s "$ZOXIDE_CACHE" ]; then
      zoxide init --cmd cd bash > "$ZOXIDE_CACHE"
    fi
    source "$ZOXIDE_CACHE"
    bind -x '"\C-f": cdi' 2>/dev/null
  fi
else
  # --- NATIVE LINUX / WSL / MACOS (DYNAMIC MODE) ---
  # Unix handles process forking in milliseconds
  
  command -v starship >/dev/null && eval "$(starship init bash)"
  
  if command -v zoxide >/dev/null; then
    eval "$(zoxide init --cmd cd bash)"
    bind -x '"\C-f": cdi' 2>/dev/null
  fi
  
  # Fastfetch is safe to run dynamically here
  if command -v fastfetch >/dev/null 2>&1; then
    fastfetch
  fi
fi
