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
alias dotfiles='brave-browser --profile-directory=Default https://github.com/Aman1337g/dotfiles & disown; exit;'


# Git aliases
alias edit='git config --global --edit'
alias g='git'
alias ga='git add'
alias gup='git add -u'
alias gall='git add .'
alias gc='git commit -m'
alias cia='git commit -am'
alias gs='git status'
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
alias mc='NuSMV'
alias md='function _mkcd() { mkdir -p "$1" && cd "$1"; }; _mkcd'
alias permit='sudo chown -R aman:aman'
alias rmshop='sudo rm /etc/xdg/autostart/io.elementary.appcenter-daemon.desktop'
alias bedit='sudo nano ~/.bashrc'
alias mint='source ~/.bashrc'
alias e='exit'
alias c='clear'


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


