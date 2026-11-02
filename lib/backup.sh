# shellcheck shell=bash
# shellcheck disable=SC2034  # variables below are consumed by the scripts that source this lib
# lib/backup.sh - Shared backup-before-link logic + target list for `setup` and `link`.
#
# Single source of truth for "which dotfiles does this repo manage" so setup's
# Stow runway-clearing and link's manual fallback can never drift apart.

BACKUP_ROOT="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/backups"
KEEP_BACKUPS="${DOTFILES_KEEP_BACKUPS:-5}"
TIMESTAMP="${TIMESTAMP:-$(date +%Y%m%d_%H%M%S)}"

# Core dotfiles, managed on every platform setup/link support.
# Format: "<package-relative-source>|<home-relative-dest>"
CORE_LINKS=(
  "bash/.bashrc|.bashrc"
  "bash/.bash_aliases|.bash_aliases"
  "bash/.profile|.profile"
  "git/.gitconfig|.gitconfig"
  "git/.ssh/config|.ssh/config"
  "nvim/.config/nvim|.config/nvim"
  "tmux/.tmux.conf|.tmux.conf"
  "starship/.config/starship.toml|.config/starship.toml"
  "fastfetch/.config/fastfetch|.config/fastfetch"
  "scripts/scripts|scripts"
  "mise/.config/mise|.config/mise"
)

# GUI/desktop dotfiles. Stow-only: `link` (Windows Git Bash fallback) never links these.
GUI_TARGETS=(
  ".config/qutebrowser"
  ".config/kitty"
  ".config/sway"
  ".config/yazi"
  ".config/zathura"
)

backup_dest_for() {
  local dest="$1"
  local rel

  if [[ "$dest" == "$HOME"/* ]]; then
    rel="${dest#"$HOME"/}"
  else
    rel="${dest#/}"
    rel="${rel//:/_}"
  fi

  printf '%s/%s' "$BACKUP_ROOT/$TIMESTAMP" "$rel"
}

backup_existing() {
  local dest="$1"
  local backup_dest

  backup_dest="$(backup_dest_for "$dest")"
  mkdir -p "$(dirname "$backup_dest")"

  echo "  📦 Backing up $dest to $backup_dest"
  mv "$dest" "$backup_dest"
}

prune_old_backups() {
  local keep="$1"
  local backup_count=0
  local old_backups=()
  local backup_dir

  [ -d "$BACKUP_ROOT" ] || return 0

  while IFS= read -r backup_dir; do
    backup_count=$((backup_count + 1))
    if [ "$backup_count" -gt "$keep" ]; then
      old_backups+=("$backup_dir")
    fi
  done < <(find "$BACKUP_ROOT" -mindepth 1 -maxdepth 1 -type d | sort -r)

  if [ "${#old_backups[@]}" -eq 0 ]; then
    return 0
  fi

  echo "🧹 Pruning old backup runs (keeping newest $keep)..."
  for backup_dir in "${old_backups[@]}"; do
    echo "  🗑️  Removing $backup_dir"
    rm -rf "$backup_dir"
  done
}
