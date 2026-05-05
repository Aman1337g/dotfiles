# Safely load .profile variables ONLY once to prevent infinite PATH growth
if [ -z "$PROFILE_LOADED" ] && [ -f "$HOME/.profile" ]; then
  export PROFILE_LOADED=1
  source "$HOME/.profile"
fi

# ── Startup profiler (set BASH_PROFILE=1 in env to enable) ──────────────────
# BASH_PROFILE=1 bash -i -c exit
_S0=$(date +%s%3N)
_bench() { [[ -n "$BASH_PROFILE" ]] && printf '[startup] %-22s %dms\n' "$1" "$(( $(date +%s%3N) - _S0 ))" >&2; }

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

# 🛑 Prevent collision with Windows Native OpenSSH in Git Bash
_AGENT_BIN="ssh-agent"
_ADD_BIN="ssh-add"
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
  _AGENT_BIN="/usr/bin/ssh-agent"
  _ADD_BIN="/usr/bin/ssh-add"
fi

_start_agent() {
  # Start agent, strip the echo commands, and save to a file
  "$_AGENT_BIN" -s | sed 's/^echo/#echo/' >"$SSH_ENV"
  chmod 600 "$SSH_ENV"
  . "$SSH_ENV" >/dev/null

  # Load keys silently
  for key in ~/.ssh/id_ed25519 ~/.ssh/wsl_spglobal ~/.ssh/id_ed25519_amandev; do
    [ -f "$key" ] && "$_ADD_BIN" "$key" >/dev/null 2>&1
  done
}

# If the env file exists, source it to get the socket paths
if [ -f "$SSH_ENV" ]; then
  . "$SSH_ENV" >/dev/null

  # Guard: skip the slow ssh-add probe entirely if the socket file is gone.
  # After a WSL restart /tmp is wiped, leaving a stale path in agent.env.
  # Calling ssh-add against a missing socket causes a ~10 s TCP timeout.
  if [ -z "$SSH_AUTH_SOCK" ] || [ ! -S "$SSH_AUTH_SOCK" ] || ! "$_ADD_BIN" -l >/dev/null 2>&1; then
    _start_agent
  fi
else
  _start_agent
fi
_bench "ssh-agent"

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

_bench "nvm setup"

# --- FZF Keybindings (Cross-Platform & Windows Safe) ---
if command -v fzf >/dev/null 2>&1; then
  # 1. Check for our universal downloaded copy first (Fixes Git Bash / Mise)
  if [ -f "$HOME/.fzf-key-bindings.bash" ]; then
    source "$HOME/.fzf-key-bindings.bash"
  # 2. Debian/Ubuntu apt location
  elif [ -f /usr/share/doc/fzf/examples/key-bindings.bash ]; then
    source /usr/share/doc/fzf/examples/key-bindings.bash
  # 3. Homebrew location (ARM Mac)
  elif [ -f /opt/homebrew/opt/fzf/shell/key-bindings.bash ]; then
    source /opt/homebrew/opt/fzf/shell/key-bindings.bash
  # 4. Homebrew location (Intel Mac)
  elif [ -f /usr/local/opt/fzf/shell/key-bindings.bash ]; then
    source /usr/local/opt/fzf/shell/key-bindings.bash
  # 5. Standard git clone fallback
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
    # Lazy-load mise: add shims to PATH immediately (tools usable at once),
    # but defer the expensive 'mise activate bash' until first cd or mise call.
    # Fixes ~35 s WSL startup caused by mise scanning the filesystem on activate.
    export PATH="$HOME/.local/share/mise/shims:$PATH"
    _mise_lazy_activate() {
      unset -f cd _mise_lazy_activate
      unalias mise 2>/dev/null
      eval "$(command mise activate bash)"
    }
    alias mise='_mise_lazy_activate; command mise'
    cd() { _mise_lazy_activate; builtin cd "$@"; }
  fi
fi
_bench "mise activate"

# ==========================================
# 4. Aliases (Must be loaded BEFORE Zoxide)
# ==========================================
[ -f "$HOME/.bash_aliases" ] && . "$HOME/.bash_aliases"
_bench "bash_aliases"

# ==========================================
# ⚡ TOOL INITIALIZATION (Cross-platform clean)
# ==========================================

# Detect Windows (Git Bash / MSYS / Cygwin)
if [[ "$OSTYPE" == msys* || "$OSTYPE" == cygwin* ]]; then
  # 🪟 WINDOWS: ultra-fast native prompt (Git-Aware)
  
  # Ensure the native Git prompt script is loaded
  if [ -f /etc/profile.d/git-prompt.sh ]; then
    . /etc/profile.d/git-prompt.sh
  fi

  # Configure the native Git prompt indicators
  export GIT_PS1_SHOWDIRTYSTATE=1       # Shows '*' for unstaged, '+' for staged changes
  export GIT_PS1_SHOWUNTRACKEDFILES=1   # Shows '%' for untracked files
  export GIT_PS1_SHOWUPSTREAM="auto"    # Shows '<', '>', or '=' relative to remote

  # Construct a multi-line, colored prompt
  # Line 1: user@host: ~/current/dir (branch *%)
  # Line 2: $
  # Construct a multi-line, colored prompt AND preserve synchronous history
  PROMPT_COMMAND='history -a; __git_ps1 "\[\033[36m\]\u\[\033[0m\]@\[\033[32m\]\h: \[\033[33;1m\]\w" "\[\033[0m\]\n\$ "'

  # --- Zoxide (Lazy Load for Git Bash) ---
  if command -v zoxide >/dev/null 2>&1; then
    _zoxide_lazy() {
      unset -f cd zi _zoxide_lazy
      eval "$(zoxide init --cmd cd bash)"
    }
    cd() { _zoxide_lazy; cd "$@"; }
    z()  { _zoxide_lazy; z "$@"; }
    zi() { _zoxide_lazy; zi "$@"; }
  fi

else
  # 🐧 LINUX / WSL / MAC / TERMUX / CONTAINERS

  # --- Starship (cached init — regenerates only when binary changes) ---
  if command -v starship >/dev/null 2>&1; then
    export STARSHIP_CONFIG="$HOME/.config/starship.toml"
    _starship_cache="$HOME/.cache/starship-init.bash"
    _starship_bin="$(command -v starship)"
    # Regenerate cache if missing or older than the starship binary itself
    if [ ! -f "$_starship_cache" ] || [ "$_starship_bin" -nt "$_starship_cache" ]; then
      mkdir -p "$HOME/.cache"
      starship init bash >| "$_starship_cache"
    fi
    source "$_starship_cache"
    unset _starship_cache _starship_bin
  fi
  _bench "starship init"

  # --- Zoxide (cached init) ---
  if command -v zoxide >/dev/null 2>&1; then
    _zoxide_cache="$HOME/.cache/zoxide-init.bash"
    _zoxide_bin="$(command -v zoxide)"
    if [ ! -f "$_zoxide_cache" ] || [ "$_zoxide_bin" -nt "$_zoxide_cache" ]; then
      mkdir -p "$HOME/.cache"
      zoxide init --cmd cd bash >| "$_zoxide_cache"
    fi
    source "$_zoxide_cache"
    bind -x '"\C-f": cdi' 2>/dev/null
    unset _zoxide_cache _zoxide_bin
  fi
  _bench "zoxide init"
fi

unset -f _bench _S0 2>/dev/null; unset _S0 2>/dev/null
