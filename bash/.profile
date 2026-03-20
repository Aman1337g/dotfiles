# ==========================================
# ~/.profile - Environment & Paths
# ==========================================

# --- Idempotent Path Appender ---
_append_path() {
  case ":$PATH:" in
    *":$1:"*) ;; # Already in PATH
    *) [ -d "$1" ] && export PATH="$1:$PATH" ;;
  esac
}

# --- XDG Base Directories ---
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"

# --- Core Variables ---
export TERM="xterm-256color"
export GTK_A11Y=none
export GTK_THEME="Nordic-darker"

# --- Build PATH Dynamically (DO THIS FIRST) ---
_append_path "$HOME/bin"
_append_path "$HOME/.local/bin"
_append_path "$HOME/scripts"
_append_path "/opt/nvim-linux64/bin"
_append_path "$HOME/.cargo/bin"

# --- Language Toolchains ---
export PYENV_ROOT="$HOME/.pyenv"
_append_path "$PYENV_ROOT/bin"

# --- Smart Editor Detection (Now PATH-Aware) ---
# 1. Main System Editor (Prefers Neovim)
if command -v nvim >/dev/null 2>&1; then
  export EDITOR="nvim"
elif command -v vim >/dev/null 2>&1; then
  export EDITOR="vim"
elif command -v vi >/dev/null 2>&1; then
  export EDITOR="vi"
elif command -v nano >/dev/null 2>&1; then
  export EDITOR="nano"
else
  export EDITOR="ed" # Ultimate POSIX fallback
fi
export VISUAL="$EDITOR"

# 2. Git Editor Override (Prefers classic Vim for quick commits)
if command -v vim >/dev/null 2>&1; then
  export GIT_EDITOR="vim"
elif command -v nvim >/dev/null 2>&1; then
  export GIT_EDITOR="nvim"
elif command -v nano >/dev/null 2>&1; then
  export GIT_EDITOR="nano"
else
  export GIT_EDITOR="vi" # The ultimate POSIX safety net
fi

# --- Cleanup ---
unset -f _append_path

# --- Load Bashrc if interactive ---
# (Ensures aliases and prompt load for login shells)
if [ -n "$BASH_VERSION" ] && [ -f "$HOME/.bashrc" ]; then
  . "$HOME/.bashrc"
fi
