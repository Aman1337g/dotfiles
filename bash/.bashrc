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
[ -f "$HOME/scripts/define" ] && bind '"\ee":"'$HOME'/scripts/define\n"'

# ==========================================
# 2. SSH Agent (Universal Env-File Pattern)
# ==========================================
export SSH_ENV="$HOME/.ssh/agent.env"

_start_agent() {
  # Start agent, strip the echo commands, and save to a file
  ssh-agent -s | sed 's/^echo/#echo/' >"$SSH_ENV"
  chmod 600 "$SSH_ENV"
  . "$SSH_ENV" >/dev/null

  # Load keys silently
  for key in ~/.ssh/id_ed25519 ~/.ssh/wsl_spglobal ~/.ssh/id_ed25519_amandev; do
    [ -f "$key" ] && ssh-add "$key" >/dev/null 2>&1
  done
}

# If the env file exists, source it to get the socket paths
if [ -f "$SSH_ENV" ]; then
  . "$SSH_ENV" >/dev/null

  # Test if the agent is alive AND reachable
  if ! ssh-add -l >/dev/null 2>&1; then
    _start_agent
  fi
else
  _start_agent
fi

# ==========================================
# 3. Tool Initialization & Wrappers
# ==========================================

# --- NVM Lazy Load (Git Bash Safe) ---
detect_nvm() {
  for nvm_candidate in "$HOME/.nvm" "${XDG_CONFIG_HOME:-$HOME/.config}/nvm"; do
    [ -d "$nvm_candidate" ] && {
      export NVM_DIR="$nvm_candidate"
      return 0
    }
  done
  return 1
}

nvm_init() {
  # 1. Use unalias instead of unset -f to cleanly remove the tripwires
  unalias nvm node npm npx 2>/dev/null
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
}

if detect_nvm; then
  # 2. nvm is a shell function, so we drop 'command' here
  alias nvm='nvm_init; nvm'

  # node, npm, and npx are real binaries, so 'command' is perfect
  alias node='nvm_init; command node'
  alias npm='nvm_init; command npm'
  alias npx='nvm_init; command npx'
fi

# --- Pyenv (auto-detect & future-proof) ---
if [ -d "$HOME/.pyenv" ]; then
  export PATH="$HOME/.pyenv/bin:$PATH"
  eval "$(pyenv init -)"
fi

# --- FZF Keybindings (No subprocess execution) ---
if command -v fzf >/dev/null 2>&1; then
  if [ -f /usr/share/doc/fzf/examples/key-bindings.bash ]; then
    source /usr/share/doc/fzf/examples/key-bindings.bash
  elif [ -f /opt/homebrew/opt/fzf/shell/key-bindings.bash ]; then
    source /opt/homebrew/opt/fzf/shell/key-bindings.bash
  elif [ -f /usr/local/opt/fzf/shell/key-bindings.bash ]; then
    source /usr/local/opt/fzf/shell/key-bindings.bash
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
# ⚡ STANDARD TOOL INITIALIZATION
# ==========================================

# 1. Initialize Starship safely
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init bash)"
fi

# 2. Zoxide
if command -v zoxide >/dev/null; then
  eval "$(zoxide init --cmd cd bash)"
  bind -x '"\C-f": cdi' 2>/dev/null
fi
