# my-kitty-config

## usage

```shell
# backup your config first
# mv ~/.config/kitty  ~/.config/kitty.bak

## suggested shell aliases (already using in my .bash_aliases)

```shell
alias icat="kitten icat"
alias s="kitten ssh"
alias d="kitten diff"
```

## Shortcuts

key name see <https://github.com/xkbcommon/libxkbcommon/blob/master/include/xkbcommon/xkbcommon-keysyms.h>

or using `kitty --debug-input` to detect keysyms

### config

keybindings explain:

<kbd>ctrl</kbd>+<kbd>a</kbd>><kbd>R</kbd> means:
press `ctrl` + `a` in the same time, release and then, press R (`shift`+`r`)

| key                                       | description   |
| ----------------------------------------- | ------------- |
| <kbd>ctrl</kbd>+<kbd>a</kbd>><kbd>R</kbd> | reload config |
| <kbd>ctrl</kbd>+<kbd>a</kbd>><kbd>E</kbd> | edit config |
| <kbd>ctrl</kbd>+<kbd>a</kbd>><kbd>D</kbd> | debug config  |

### session

| key                                       | description                         |
| ----------------------------------------- | ----------------------------------- |
| <kbd>ctrl</kbd>+<kbd>a</kbd>><kbd>s</kbd> | save current layout to session file |

### tab

| key                                           | description        |
| --------------------------------------------- | ------------------ |
| <kbd>ctrl</kbd>+<kbd>shift</kbd>+<kbd>←</kbd> | goto previous tab        |
| <kbd>ctrl</kbd>+<kbd>shift</kbd>+<kbd>→</kbd> | goto next tab           |
| <kbd>ctrl</kbd>+<kbd>shift</kbd>+<kbd>k</kbd> | goto previous tab        |
| <kbd>ctrl</kbd>+<kbd>shift</kbd>+<kbd>j</kbd> | goto next tab           |
| <kbd>ctrl</kbd>+<kbd>shift</kbd>+<kbd>,</kbd> | move tab backward  |
| <kbd>ctrl</kbd>+<kbd>shift</kbd>+<kbd>.</kbd> | move tab forward   |
| <kbd>ctrl</kbd>+<kbd>a</kbd>><kbd>,</kbd>     | change tab title   |
| <kbd>ctrl</kbd>+<kbd>a</kbd>><kbd>c</kbd>     | create new tab     |
| <kbd>ctrl</kbd>+<kbd>a</kbd>><kbd>x</kbd>     | close window / tab |

### os window

| key                          | description       |
| ---------------------------- | ----------------- |
| <kbd>ctrl</kbd>+<kbd>q</kbd> | quit kitty        |
| <kbd>f11</kbd>               | toggle fullscreen |

### window

| key                                                         | description                  |
| ----------------------------------------------------------- | ---------------------------- |
| <kbd>alt</kbd>+<kbd>g</kbd>                   | horizontal split with cwd    |
| <kbd>alt</kbd>+<kbd>shift</kbd>+<kbd>g</kbd>  | horizontal split             |
| <kbd>alt</kbd>+<kbd>v</kbd>                  | vertial split with cwd       |
| <kbd>alt</kbd>+<kbd>shift</kbd>+<kbd>v</kbd> | vertial split                |
| <kbd>ctrl</kbd>+<kbd>a</kbd>><kbd>x</kbd>                   | close window                 |
| <kbd>ctrl</kbd>+<kbd>a</kbd>><kbd>z</kbd>                   | zoom (maxmize) window        |
| <kbd>ctrl</kbd>+<kbd>shift</kbd>+<kbd>l</kbd>                   | zoom (maxmize) window        |
| <kbd>ctrl</kbd>+<kbd>shift</kbd>+<kbd>r</kbd>               | resize window                |
| <kbd>ctrl</kbd>+<kbd>←</kbd>                                | goto left window               |
| <kbd>ctrl</kbd>+<kbd>→</kbd>                                | goto right window              |
| <kbd>ctrl</kbd>+<kbd>↑</kbd>                                | goto up window                 |
| <kbd>ctrl</kbd>+<kbd>↓</kbd>                                | goto down window               |
| <kbd>alt</kbd>+<kbd>h</kbd>                  | goto left window               |
| <kbd>alt</kbd>+<kbd>l</kbd>                  | goto right window              |
| <kbd>alt</kbd>+<kbd>k</kbd>                  | goto up window                 |
| <kbd>alt</kbd>+<kbd>j</kbd>                  | goto down window               |
| <kbd>alt</kbd>+<kbd>shift</kbd>+<kbd>h</kbd>                               | move current window to left  |
| <kbd>alt</kbd>+<kbd>shift</kbd>+<kbd>l</kbd>                               | move current window to right |
| <kbd>alt</kbd>+<kbd>shift</kbd>+<kbd>k</kbd>                               | move current window to up    |
| <kbd>alt</kbd>+<kbd>shift</kbd>+<kbd>j</kbd>                               | move current window to down  |
| <kbd>ctrl</kbd>+<kbd>shift</kbd>+<kbd>f</kbd>                               | move current window forward  |
| <kbd>ctrl</kbd>+<kbd>shift</kbd>+<kbd>b</kbd>                               | move current window backward  |
| <kbd>alt</kbd>+<kbd>n</kbd>                                 | resize window narrower       |
| <kbd>alt</kbd>+<kbd>w</kbd>                                 | resize window wider          |
| <kbd>alt</kbd>+<kbd>u</kbd>                                 | resize window taller         |
| <kbd>alt</kbd>+<kbd>d</kbd>                                 | resize window shorter        |
| <kbd>ctrl</kbd>+<kbd>shift</kbd>+<kbd>enter</kbd>                             | resize window reset          |

### font

| key                          | description     |
| ---------------------------- | --------------- |
| <kbd>ctrl</kbd>+<kbd>=</kbd> | font size +     |
| <kbd>ctrl</kbd>+<kbd>-</kbd> | font size -     |
| <kbd>ctrl</kbd>+<kbd>0</kbd> | font size reset |

### misc

| key                                                       | description                                                                          |
| --------------------------------------------------------- | ------------------------------------------------------------------------------------ |
| <kbd>ctrl</kbd>+<kbd>a</kbd>><kbd>t</kbd>                 | kitten themes                                                                        |
| <kbd>ctrl</kbd>+<kbd>a</kbd>><kbd>space</kbd>             | copy pasting with hints like [tmux-thumbs](https://github.com/fcsonline/tmux-thumbs) |
| <kbd>ctrl</kbd>+<kbd>a</kbd>><kbd>ctrl</kbd>+<kbd>a</kbd> | send real <kbd>ctrl</kbd>+<kbd>a</kbd> (emacs shortcut <kbd>Home</kbd>)              |

### clipboard

| key                                                       | description                                                                          |
| --------------------------------------------------------- | ------------------------------------------------------------------------------------ |
| <kbd>ctrl</kbd>+<kbd>v</kbd>                                    | paste from clipboard                                                                        |
| <kbd>ctrl</kbd>+<kbd>shift</kbd>+<kbd>s</kbd>             | paste from selection |
| <kbd>ctrl</kbd>+<kbd>space</kbd>                                | copy to clipboard              |

### scrolling 

| key                                                       | description                                                                          |
| --------------------------------------------------------- | ------------------------------------------------------------------------------------ |
| <kbd>ctrl</kbd>+<kbd>k</kbd>                                   | scroll line up                                                                        |
| <kbd>ctrl</kbd>+<kbd>j</kbd>                                   | scroll line down |


## session restore

> if you have used <kbd>ctrl</kbd>+<kbd>a</kbd>><kbd>s</kbd> generate the session, you do not need this.

you can create your session file under `~/.config/kitty`, let's say the filename is `session.conf`

change `startup_session none` to `startup_session session.conf`

create `session.conf` like this:

```ini
new_tab home
layout splits
cd ~
launch zsh
focus

new_tab work
cd ~/work
launch zsh

new_tab nvim
cd ~/.config/nvim
launch zsh

new_tab go
cd ~/repo/go
launch zsh

new_tab rust
cd ~/repo/rust
launch zsh
```

## kitty docs

Keyboard shortcuts <https://sw.kovidgoyal.net/kitty/conf/#keyboard-shortcuts>

The launch command syntax reference <https://sw.kovidgoyal.net/kitty/launch/#syntax-reference>

## troubleshooting

the behavior of `listen_on` differs from the behavior of `--listen-on` cli flag.

the cli one is exactly the same.

the config file one will append a random postfix to the socket name, this is strange logic.

start kitty:
```
kitty -o allow_remote_control=yes --listen-on unix:/run/user/1000/kitty.sock
```

on other terminal:

```
 kitty @ --to unix:/run/user/1000/kitty.sock launch --type=tab --cwd "/tmp" --tab-title "My Tab" --keep-focus bash
```

## credits

- https://github.com/ttys3/my-kitty-config
