alias dotfiles='brave-browser --profile-directory=Default https://github.com/Aman1337g/dotfiles & disown; exit'


# Change directory aliases
alias home='cd ~'
alias cd..='cd ..'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'


# Git aliases
alias addup='git add -u'
alias addall='git add .'
alias branch='git branch'
alias checkout='git checkout'
alias clone='git clone'
alias commit='git commit -m'
alias fetch='git fetch'
alias pull='git pull origin'
alias push='git push origin'
alias s='git status'  # 'status' is protected name so using 'stat' instead
alias tag='git tag'
alias newtag='git tag -a'
alias edit='git config --global --edit'
alias gl='git log --oneline --decorate --graph'
alias lg="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative"


# Misc aliases
alias uu='sudo apt update && sudo apt upgrade'
alias nr='sudo nextdns restart'
alias md='function _mkcd() { mkdir -p "$1" && cd "$1"; }; _mkcd'
alias permit='sudo chown -R aman:aman'
alias rmshop='sudo rm /etc/xdg/autostart/io.elementary.appcenter-daemon.desktop'
alias bedit='sudo nano ~/.bashrc'
alias mint='source ~/.bashrc'
alias e='exit'
alias c='clear'
alias i='sudo apt install'
alias purge='sudo apt purge'
alias atrm='sudo apt autoremove'


# network commands
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


# tmux aliases
alias t='tmux'
alias tls='tmux ls'
alias ta='tmux attach -t'
alias tnew='tmux new -s'
alias tkill='tmux kill-session -t'
alias tks='tmux kill-server'


# Docker aliases
alias d='docker'
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


# Kitty Reload
kr() {
    kill -SIGUSR1 $(pidof kitty)
}


# the terminal rickroll
alias rr="curl -s -L https://raw.githubusercontent.com/keroserene/rickrollrc/master/roll.sh | bash"
