alias dotfiles='brave-browser --profile-directory=Default https://github.com/Aman1337g/dotfiles & disown; exit'


# Change directory aliases
alias home='cd ~'
alias cd..='cd ..'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'


# Git aliases
alias a='git add'
alias au='git add -u'
alias a.='git add .'
alias br='git branch'
alias co='git checkout'
alias clone='git clone'
alias ci='git commit -m'
alias fetch='git fetch'
alias pull='git pull origin'
alias push='git push origin'
alias s='git status'  # 'status' is protected name so using 's' instead
alias tag='git tag'
alias newtag='git tag -a'
alias gl='git log --oneline --decorate --graph'
alias lg="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative"
alias diff="git diff"


# Misc aliases
alias uu='sudo apt update && sudo apt upgrade'
alias ai='apt info'
alias nr='sudo nextdns restart'
alias md='function _mkcd() { mkdir -p "$1" && cd "$1"; }; _mkcd'
alias rmshop='sudo rm /etc/xdg/autostart/io.elementary.appcenter-daemon.desktop'
alias bedit='nvim ~/.bashrc'
alias aedit='nvim ~/.bash_aliases'
alias gedit='nvim ~/.gitconfig'
alias mint='source ~/.bashrc'
alias e='exit'
alias c='clear'
alias b='bluetoothctl'
alias i='sudo apt install'
alias purge='sudo apt purge'
alias atrm='sudo apt autoremove'
alias n='nano'
alias T='icat ~/Desktop/Time\ table\ 7th\ semester.png'
alias count="for t in files links directories; do \
  case \$t in \
    files) type_flag='f' ;; \
    links) type_flag='l' ;; \
    directories) type_flag='d' ;; \
  esac; \
  count=\$(find . -type \$type_flag 2>/dev/null | wc -l); \
  echo \$count \$t; \
done"                                                        # counting files, directories and links
alias da='date'                         # date and time
crp() {
    realpath "$1" | xclip -selection clipboard
}
alias iuz='curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh'  # installing latest zoxide binary in ~/.local/bin/ 
alias favset='dconf write /org/gnome/shell/favorite-apps "['\''brave-browser.desktop'\'', '\''google-chrome.desktop'\'', '\''code.desktop'\'', '\''libreoffice-writer.desktop'\'', '\''org.gnome.Nautilus.desktop'\'']"'
alias o='open'


# dconf dumping commands
alias dmk='dconf dump /org/gnome/settings-daemon/plugins/media-keys/ > /home/aman/.dotfiles/debian-custom-keybindings.ini'
alias dwmk='dconf dump /org/gnome/desktop/wm/keybindings/ > /home/aman/.dotfiles/debian-wm-keybindings.ini'


# ddterm
alias dt='com.github.amezin.ddterm'


# fastfetch
alias ff='fastfetch'


# Neovim commands
alias v='/opt/nvim-linux64/bin/nvim'
sv() {
    sudo -E /opt/nvim-linux64/bin/nvim "$@"
}


# Syncthing
alias ms='syncthing --no-browser'  # mind sync


# Qutebrowser update
alias qu='cd $HOME/qutebrowser/ && scripts/mkvenv.py --update && exit'


# Permission commands
alias mx='chmod a+x'
alias x='chmod u+x'
alias permit='sudo chown -R aman:aman'


# Nicer cat
alias cat='batcat'


# fuzzy finding
alias fp='fzf --preview="bat --color=always {}"'


# Copy commands
alias cp='cp -vi'
alias mv='mv -vi'
alias cpv='rsync -avh --info=progress2'  # verbose copying


# Alias's to show disk space, free space and space used in a folder
alias ds="du -Sh | sort -h -r | less"   # diskspace used by file and directory in descending order human readable 
alias fss='du -h --max-depth=1 | grep -v "^\." | sort -rh'  # space used by folders in . directory descending in human readable format
alias df='df -hT'               # human-readable sizes
alias free='free -m'           # show sizes in MB


# Process commands
alias psa="ps auxf"
alias psgrep="ps aux | grep -v grep | grep -i -e VSZ -e"
alias psmem='ps auxf | sort -nr -k 4'
alias pscpu='ps auxf | sort -nr -k 3'
alias topcpu="/bin/ps -eo pcpu,pid,user,args | sort -k 1 -r | head -10"   # top 10 processes according to cpu usage


# Finding string in files and files in folders
fstr() {
    # -i case-insensitive
    # -I ignore binary files
    # -H causes filename to be printed
    # -r recursive search
    # -n causes line number to be printed
    # optional: -F treat search term as a literal, not a regular expression
    # optional: -l only print filenames and not the matching lines ex. grep -irl "$1" *
    grep -IHrn --color=always "$1" . | less -r
}
alias f="find . | grep "   # searcing file in current folder


# Archive extraction
SAVEIFS=$IFS
IFS="$(printf '\n\t')"

function ex {
 if [ $# -eq 0 ]; then
    # display usage if no parameters given
    echo "Usage: extract <path/file_name>.<zip|rar|bz2|gz|tar|tbz2|tgz|Z|7z|xz|ex|tar.bz2|tar.gz|tar.xz|.zlib|.cso|.zst>"
    echo "       extract <path/file_name_1.ext> [path/file_name_2.ext] [path/file_name_3.ext]"
 fi
    for n in "$@"; do
        if [ ! -f "$n" ]; then
            echo "'$n' - file doesn't exist"
            return 1
        fi

        case "${n%,}" in
          *.cbt|*.tar.bz2|*.tar.gz|*.tar.xz|*.tbz2|*.tgz|*.txz|*.tar)
                       tar zxvf "$n"       ;;
          *.lzma)      unlzma ./"$n"      ;;
          *.bz2)       bunzip2 ./"$n"     ;;
          *.cbr|*.rar) unrar x -ad ./"$n" ;;
          *.gz)        gunzip ./"$n"      ;;
          *.cbz|*.epub|*.zip) unzip ./"$n"   ;;
          *.z)         uncompress ./"$n"  ;;
          *.7z|*.apk|*.arj|*.cab|*.cb7|*.chm|*.deb|*.iso|*.lzh|*.msi|*.pkg|*.rpm|*.udf|*.wim|*.xar|*.vhd)
                       7z x ./"$n"        ;;
          *.xz)        unxz ./"$n"        ;;
          *.exe)       cabextract ./"$n"  ;;
          *.cpio)      cpio -id < ./"$n"  ;;
          *.cba|*.ace) unace x ./"$n"     ;;
          *.zpaq)      zpaq x ./"$n"      ;;
          *.arc)       arc e ./"$n"       ;;
          *.cso)       ciso 0 ./"$n" ./"$n.iso" && \
                            extract "$n.iso" && \rm -f "$n" ;;
          *.zlib)      zlib-flate -uncompress < ./"$n" > ./"$n.tmp" && \
                            mv ./"$n.tmp" ./"${n%.*zlib}" && rm -f "$n"   ;;
          *.dmg)
                      hdiutil mount ./"$n" -mountpoint "./$n.mounted" ;;
          *.tar.zst)  tar -I zstd -xvf ./"$n"  ;;
          *.zst)      zstd -d ./"$n"  ;;
          *)
                      echo "extract: '$n' - unknown archive method"
                      return 1
                      ;;
        esac
    done
}

IFS=$SAVEIFS


# Network commands
connect() {
    if [ $# -lt 1 ]; then
        echo "Usage: connect <network_name> [password]"
        return 1
    fi

    local SSID="$1"
    local PASSWORD="${2:-}"

    nmcli device wifi connect "$SSID" ${PASSWORD:+password "$PASSWORD"}

    if [ $? -eq 0 ]; then
        echo "Connected to $SSID"
    else
        echo "Failed to connect to $SSID"
    fi
}
alias openports='netstat -nape --inet'
ipaddr() {
    local internal_ip external_ip
    # Internal IP Lookup
    if command -v ip &> /dev/null; then
        internal_ip=$(ip addr show | awk '/inet / && !/127.0.0.1/ && !/:.*:/ {gsub(/\/.*/, "", $2); print $2; exit}')
    else
        internal_ip=$(ifconfig | awk '/inet / && !/127.0.0.1/ {print $2; exit}')
    fi

    # External IP Lookup
    external_ip=$(curl -s ifconfig.me)

    echo "Internal IP: $internal_ip"
    echo "External IP: $external_ip"
}


# # Tmux aliases
# alias t='tmux'
# alias tls='tmux ls'
# alias ta='tmux attach -t'
# alias tnew='tmux new -s'
# alias tkill='tmux kill-session -t'
# alias tks='tmux kill-server'


# Docker aliases
alias dk='docker'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias dimages='docker images'
alias dbuild='docker build'
alias dstopall='docker stop $(docker ps -aq)'
alias drmi='docker rmi'
alias dclean='docker system prune -a'
alias dcompose='docker-compose'


# Python aliases
alias p='python'
alias vc="python -m virtualenv"
alias venv="python -m venv"


# Kitty aliases
kr() {
    kill -SIGUSR1 $(pidof kitty)
}
alias icat="kitten icat"
alias d="kitten diff"
alias kd="git difftool --no-symlinks --dir-diff"
alias ku="curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin"

# The terminal rickroll
alias rr="curl -s -L https://raw.githubusercontent.com/keroserene/rickrollrc/master/roll.sh | bash"
