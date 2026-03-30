# ==========================================
# ~/.bash_aliases - Complete Toolkit
# ==========================================

# --- Helpers ---
_has() { command -v "$1" >/dev/null 2>&1; }

# ==========================================
# Core Overrides & Fallbacks
# ==========================================
if _has eza; then
  alias ls='eza -al --color=always --group-directories-first'
  alias la='eza -a --color=always --group-directories-first'
  alias lt='eza -aT --color=always --group-directories-first'
  alias l.='eza -a | grep "^\."'
  alias l..='eza -al --color=always --group-directories-first ../../'
  alias l...='eza -al --color=always --group-directories-first ../../../'
else
  alias ls='ls --color=auto'
  alias ll='ls -alF'
  alias la='ls -A'
fi

if _has batcat; then
  alias cat='batcat'
elif _has bat; then
  alias cat='bat'
fi

alias grep='grep --color=auto'
alias cp='cp -vi'
alias mv='mv -vi'
alias cpv='rsync -avh --info=progress2'

# ==========================================
# Navigation & Basics
# ==========================================
alias home='cd ~'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias c='clear'
alias e='exit'
alias o='open'
md() { mkdir -p "$1" && cd "$1" || return 1; }

# ==========================================
# Config & Editors (Uses $EDITOR fallback)
# ==========================================
alias dotfiles='brave-browser --profile-directory=Default https://github.com/Aman1337g/dotfiles >/dev/null 2>&1 & disown; exit'
alias bedit='$EDITOR ~/.bashrc'
alias aedit='$EDITOR ~/.bash_aliases'
alias pedit='$EDITOR ~/.profile'
alias gedit='$EDITOR ~/.gitconfig'
alias mint='source ~/.bashrc'
alias v='$EDITOR'
sv() { sudo -E $EDITOR "$@"; }

# ==========================================
# Package Management
# ==========================================
if _has apt; then
  alias uu='sudo apt update && sudo apt upgrade -y'
  alias ai='apt info'
  alias i='sudo apt install'
  alias purge='sudo apt purge'
  alias atrm='sudo apt autoremove -y'
  alias dp='apt rdepends --installed'
fi

# ==========================================
# Git Workflow (Aliases)
# ==========================================
alias s='git status'
alias a='git add'
alias au='git add -u'
alias a.='git add .'
alias br='git branch'
alias co='git checkout'
alias ci='git commit -m'
alias fetch='git fetch'
alias push='git push origin'
alias diff='git diff'
alias sw='git switch'
alias gl='git log --graph --oneline --decorate'
alias gla='git log --graph --oneline --decorate --all'
alias lg="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias lga="git log --graph --all --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias lo='git log --oneline'
alias ll='git log --oneline -n 10'
alias amend='git commit --amend'
alias ane='git commit --amend --no-edit'
alias pcf='git push --force-with-lease'
alias clone='git clone'

# ==========================================
# Git Workflow (Functions)
# ==========================================
_get_current_branch() {
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
    echo "❌ Not a git repo" >&2
    return 1
  }
  local branch
  branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  [ "$branch" = "HEAD" ] && {
    echo "❌ Detached HEAD" >&2
    return 1
  }
  echo "$branch"
}

_get_ado_ticket() {
  local branch
  branch=$(_get_current_branch) || return 1
  if [[ "$branch" =~ (ADO-[0-9]+) ]]; then
    echo "${BASH_REMATCH[1]}"
  fi
}

dc() {
  set -f
  local ticket type msg body commit_format

  ticket=$(_get_ado_ticket) || {
    set +f
    return 1
  }

  if [ $# -gt 0 ]; then
    type="$1"
    shift
  else
    type="fix"
  fi

  # If exactly 2 arguments remain, treat them as "Subject" and "Body"
  if [ $# -eq 2 ]; then
    msg="$1"
    # Safely translate literal '\n' and '\t' into real Bash newlines and tabs
    body="${2//\\n/$'\n'}"
    body="${body//\\t/$'\t'}"
  else
    # Legacy behavior: combine all remaining words into the subject
    msg="${*:-dummy commit}"
    body=""
  fi

  if [ -n "$ticket" ]; then
    commit_format="${type}(${ticket}): ${msg}"
  else
    commit_format="${type}: ${msg}"
  fi

  # Git natively separates multiple -m flags with a blank line
  if [ -n "$body" ]; then
    git commit -m "$commit_format" -m "$body"
  else
    git commit -m "$commit_format"
  fi

  set +f
}

pc() {
  local branch
  branch=$(_get_current_branch) || return 1
  git push -u "${1:-origin}" "$branch"
}

pl() {
  local branch
  branch=$(_get_current_branch) || return 1
  git pull "${1:-origin}" "$branch"
}

gbc() {
  git branch --merged | grep -E -v "(^\*|main|master|develop)" | xargs -r git branch -d
}

gtog() {
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
    echo "❌ Not a git repo" >&2
    return 1
  }

  local current_email personal_email work_email name
  personal_email="97891757+Aman1337g@users.noreply.github.com"
  name="Aman Kumar Gupta"

  if [ -f "$HOME/.gitconfig-work" ]; then
    work_email=$(git config -f "$HOME/.gitconfig-work" user.email)
  else
    echo "❌ Error: ~/.gitconfig-work not found. Cannot determine work email." >&2
    return 1
  fi

  current_email=$(git config user.email)

  if [ "$current_email" = "$work_email" ]; then
    echo "🔄 Switching to 👤 PERSONAL profile for this repository..."
    git config --local user.email "$personal_email"
    git config --local user.name "$name"
  else
    echo "🏢 Switching to 💼 WORK profile for this repository..."
    git config --local user.email "$work_email"
    git config --local user.name "$name"
  fi

  echo "✅ Identity set: $(git config user.name) <$(git config user.email)>"
}

# ==========================================
# Disk, Mem & System Monitoring
# ==========================================
alias ds="du -Sh | sort -h -r | less"
alias fss='du -h --max-depth=1 | grep -E -v "^\." | sort -rh'
alias df='df -hT'
alias free='free -m'
alias psa="ps auxf"
alias psgrep="ps aux | grep -v grep | grep -i -e VSZ -e"
alias psmem='ps auxf | sort -nr -k 4'
alias pscpu='ps auxf | sort -nr -k 3'
alias topcpu="/bin/ps -eo pcpu,pid,user,args | sort -k 1 -r | head -10"

# ==========================================
# Searching
# ==========================================
alias fp='fzf --preview="bat --color=always {}"'
alias f="find . | grep "
fstr() {
  if [ -z "$1" ]; then
    echo "Usage: fstr <search_term>"
    return 1
  fi
  grep -IHrn --color=always "$1" . | less -r
}
cnt() {
  echo "Files: $(find . -maxdepth 1 -type f 2>/dev/null | wc -l)"
  echo "Dirs:  $(find . -maxdepth 1 -type d 2>/dev/null | wc -l)"
  echo "Links: $(find . -maxdepth 1 -type l 2>/dev/null | wc -l)"
}

# ==========================================
# Network
# ==========================================
alias openports='netstat -nape --inet'
connect() {
  if [ -z "$1" ]; then
    echo "Usage: connect <network_name> [password]"
    return 1
  fi
  nmcli device wifi connect "$1" ${2:+password "$2"}
}
ipaddr() {
  echo "Internal IP: $(hostname -I 2>/dev/null | awk '{print $1}')"
  echo "External IP: $(curl -s --max-time 3 ifconfig.me 2>/dev/null || echo "Unavailable")"
}

# ==========================================
# Docker, Python & Terraform
# ==========================================
alias dk='docker'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias dimages='docker images'
alias dbuild='docker build'
alias dstopall='docker stop $(docker ps -aq 2>/dev/null) 2>/dev/null'
alias drmi='docker rmi'
alias dclean='docker system prune -af'
alias dcompose='docker-compose'
alias p='python'
alias venv='python -m venv'
alias t='terraform'
alias tfmt='terraform fmt --recursive'

# ==========================================
# Desktop & Media (Kitty/GNOME/Etc)
# ==========================================
alias icat="kitten icat"
alias d="kitten diff"
alias kd="git difftool --no-symlinks --dir-diff"
kr() { kill -SIGUSR1 $(pidof kitty 2>/dev/null) 2>/dev/null; }
alias T='icat ~/Desktop/Time\ table\ 7th\ semester.png'
alias favset='dconf write /org/gnome/shell/favorite-apps "['\''brave-browser.desktop'\'', '\''google-chrome.desktop'\'', '\''code.desktop'\'', '\''libreoffice-writer.desktop'\'', '\''org.gnome.Nautilus.desktop'\'']"'
alias dmk='dconf dump /org/gnome/settings-daemon/plugins/media-keys/ > "$HOME/.dotfiles/debian-custom-keybindings.ini"'
alias dwmk='dconf dump /org/gnome/desktop/wm/keybindings/ > "$HOME/.dotfiles/debian-wm-keybindings.ini"'
alias l='light -S'
alias m='mocp'
alias anime='ani-cli -d '

# ==========================================
# Utilities & Maintenance
# ==========================================
alias mx='chmod a+x'
alias permit='sudo chown -R "${USER}:${USER}"'
alias da='date'
alias ms='syncthing --no-browser'
alias dt='com.github.amezin.ddterm'
alias ff='fastfetch'
alias iuz='curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh'
alias nr='sudo nextdns restart'
alias rmshop='sudo rm -f /etc/xdg/autostart/io.elementary.appcenter-daemon.desktop 2>/dev/null'
alias qu='cd "$HOME/qutebrowser/" && scripts/mkvenv.py --update && exit'
alias rr="curl -s -L https://raw.githubusercontent.com/keroserene/rickrollrc/master/roll.sh | bash"
# Windows-to-Linux Line Ending Converter (Bulletproof)
wtl() {
  if [ $# -eq 0 ]; then
    echo "Usage: wtl <file1> [file2...]"
    return 1
  fi
  for file in "$@"; do
    if [ -f "$file" ]; then
      tr -d '\r' <"$file" >"${file}.tmp" && mv "${file}.tmp" "$file"
      echo "✅ Cleaned CRLF from: $file"
    else
      echo "❌ File not found: $file"
    fi
  done
}

# System Maintenance Scripts
alias upgrade='~/scripts/upgrade'
alias clean='~/scripts/cleanup'
alias update-all='upgrade && clean'
alias deploy='~/.dotfiles/setup' # Windows "GitOps" Deployment

# ==========================================
# Complex Functions (Pomodoro, Clipboard, Extract)
# ==========================================

# View your Pomodoro progress (Last 10 sessions)
alias pomo-stats='tail -n 10 ~/pomodoro_log.md | column -t -s "|"'

pomo() {
  # Arguments: pomo "Task Name" [work_min] [break_min] [cycles]
  local task="${1:-General Focus}"
  local work=${2:-25}
  local break_duration=${3:-5}
  local cycles=${4:-4}
  local log_file="$HOME/pomodoro_log.md"

  # Live countdown helper
  countdown() {
    local secs=$(($1 * 60))
    while [ $secs -gt 0 ]; do
      printf "\r⏳ %02d:%02d " $((secs / 60)) $((secs % 60))
      sleep 1
      : $((secs--))
    done
    echo ""
  }

  # Cross-platform alert wrapper
  send_alert() {
    local title="$1"
    local msg="$2"

    if command -v notify-send >/dev/null 2>&1; then
      notify-send "$title" "$msg" >/dev/null 2>&1
    elif command -v osascript >/dev/null 2>&1; then
      osascript -e "display notification \"$msg\" with title \"$title\"" >/dev/null 2>&1
    fi

    if grep -qi microsoft /proc/version 2>/dev/null; then
      (powershell.exe -c "(New-Object Media.SoundPlayer 'C:\Windows\Media\notify.wav').PlaySync()" >/dev/null 2>&1 &)
    elif [[ "$OSTYPE" == "darwin"* ]]; then
      (afplay /System/Library/Sounds/Glass.aiff >/dev/null 2>&1 &)
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
      if command -v paplay >/dev/null 2>&1 && [ -f /usr/share/sounds/freedesktop/stereo/complete.oga ]; then
        (paplay /usr/share/sounds/freedesktop/stereo/complete.oga >/dev/null 2>&1 &)
      elif command -v aplay >/dev/null 2>&1 && [ -f /usr/share/sounds/alsa/Front_Center.wav ]; then
        (aplay /usr/share/sounds/alsa/Front_Center.wav >/dev/null 2>&1 &)
      fi
    fi
  }

  clear
  echo "🍅 Starting Pomodoro for: **$task**"
  echo "   $cycles cycles of $work min work / $break_duration min break."

  for ((i = 1; i <= cycles; i++)); do
    echo "-----------------------------------"
    echo "🔥 Cycle $i/$cycles: Time to focus!"
    send_alert "Pomodoro" "Cycle $i: Focus for $work minutes!"
    countdown $work

    if [ $i -lt $cycles ]; then
      echo "☕ Break time! Step away for $break_duration minutes."
      send_alert "Pomodoro Break" "Take $break_duration minutes off."
      countdown $break_duration
    else
      echo "🎉 All cycles complete. Great job!"
      send_alert "Pomodoro Done" "Session complete!"

      if [ ! -f "$log_file" ]; then
        echo "# 🍅 Pomodoro Session Log" >"$log_file"
        echo "A record of completed focus cycles." >>"$log_file"
        echo "" >>"$log_file"
      fi

      local timestamp=$(date +'%Y-%m-%d %I:%M %p')
      local total_mins=$((work * cycles))

      echo "- [x] **$timestamp** | ⏱️ $total_mins min ($cycles cycles) | **Task:** $task" >>"$log_file"
      echo "📝 Logged session to $log_file"
    fi
  done
}

crp() {
  local path
  path=$(realpath "$1" 2>/dev/null) || {
    echo "❌ Invalid path"
    return 1
  }
  if _has pbcopy; then
    echo "$path" | pbcopy
  elif _has wl-copy; then
    echo "$path" | wl-copy
  elif _has xclip; then
    echo "$path" | xclip -selection clipboard
  else
    echo "❌ No clipboard utility found."
    return 1
  fi
}

pdf() {
  local file
  # Set your preferred viewer here: "evince" or "zathura"
  local VIEWER="evince"

  # Find and select the PDF (case-insensitive, hiding permission errors)
  file=$(find . -maxdepth 5 -iname "*.pdf" 2>/dev/null | fzf -e -i --prompt="Open PDF ($VIEWER)> ")

  if [ -n "$file" ]; then
    if [ "$VIEWER" = "evince" ]; then
      if ! command -v evince &>/dev/null; then
        echo "Error: evince is not installed."
        return 1
      fi
      (evince --fullscreen "$file" >/dev/null 2>&1 &)
    elif [ "$VIEWER" = "zathura" ]; then
      if ! command -v zathura &>/dev/null; then
        echo "Error: zathura is not installed."
        return 1
      fi
      (zathura --mode fullscreen --config-dir="$HOME/.config/zathura" "$file" >/dev/null 2>&1 &)
    else
      echo "Error: Unknown viewer set in the function."
    fi
  fi
}

extract() {
  if [ $# -eq 0 ]; then
    echo "Usage: extract <archive_file>"
    return 1
  fi
  for file in "$@"; do
    if [ ! -f "$file" ]; then
      echo "❌ '$file' does not exist."
      continue
    fi
    case "$file" in
    *.tar.bz2 | *.tbz2) tar xvjf "$file" ;;
    *.tar.gz | *.tgz) tar xvzf "$file" ;;
    *.tar.xz | *.txz) tar xvJf "$file" ;;
    *.tar) tar xvf "$file" ;;
    *.bz2) bunzip2 "$file" ;;
    *.rar) unrar x "$file" ;;
    *.gz) gunzip "$file" ;;
    *.zip | *.cbz) unzip "$file" ;;
    *.Z) uncompress "$file" ;;
    *.7z) 7z x "$file" ;;
    *) echo "❌ '$file' - unknown archive method" ;;
    esac
  done
}
