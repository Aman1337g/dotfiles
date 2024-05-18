# Define a function for dotfile management
config() {
    /usr/bin/git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" "$@"
}
# Dotfile management functions
dots() {
    config status "$@"
}
dot() {
    config add "$@"
}
dota() {
    config add -u "$@"
}
dotco() {
    config checkout "$@"
}
dotp() {
    config push "$@"
}
dotc() {
    config commit -am "$@"
}
dotpull() {
    config pull "$@"
}
dotlg() {
    config log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative "$@"
}
dotf() {
    config diff "$@"
}
dotls() {
    config ls-tree -r HEAD
}
alias dotfiles='brave-browser --profile-directory=Default https://github.com/Aman1337g/dotfiles & disown; exit'


# Git aliases
alias edit='git config --global --edit'
alias g='git'
alias ga='git add'
alias gup='git add -u'
alias gall='git add .'
alias gc='git commit -m'
alias cia='git commit -am'
alias s='git status'
alias gl='git log --oneline --decorate --graph'
alias lg="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative"
alias gd='git diff'
alias gco='git checkout'
alias br='git branch'
alias gp='git pull'
alias gf='git fetch'
alias gps='git push'
alias clone='git clone'
alias gsh='git stash'
alias rebase='git pull --rebase'


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
