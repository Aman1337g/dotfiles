# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
  # include .bashrc if it exists
  if [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
  fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ]; then
  PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's local bin if it exists
if [ -d "$HOME/.local/bin" ]; then
  PATH="$HOME/.local/bin:$PATH"
fi

# Custom PATH additions (Linux + Windows interop)
export PATH="/home/aman/.local/bin:/home/aman/scripts:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/usr/lib/wsl/lib:/mnt/c/Users/AMAN.GUPTA7/bin:/mnt/c/Program Files/Git/mingw64/bin:/mnt/c/Program Files/Git/usr/local/bin:/mnt/c/Program Files/Git/usr/bin:/mnt/c/Windows/system32:/mnt/c/Windows:/mnt/c/Windows/System32/Wbem:/mnt/c/Windows/System32/WindowsPowerShell/v1.0:/mnt/c/Windows/System32/OpenSSH:/mnt/c/Program Files/PowerShell/7:/mnt/c/Program Files/Microsoft VS Code/bin:/mnt/c/Program Files/Git/cmd:/mnt/c/Windows/system32/config/systemprofile/AppData/Local/Microsoft/WindowsApps:/mnt/c/Program Files/Terraform:/mnt/c/Users/AMAN.GUPTA7/AppData/Local/Microsoft/WindowsApps:/mnt/c/Tools:/mnt/c/Users/AMAN.GUPTA7/AppData/Local/GitHubDesktop/bin:/mnt/c/Program Files/Git/usr/bin/vendor_perl:/mnt/c/Program Files/Git/usr/bin/core_perl:/snap/bin"

# Optional: Python and Rust toolchains
# export PYENV_ROOT="$HOME/.pyenv"
# command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
# eval "$(pyenv init -)"
# . "$HOME/.cargo/env"
