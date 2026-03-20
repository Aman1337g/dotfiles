# 💻 Aman's Dotfiles

A production-grade, cross-platform collection of dotfiles and environment configurations. Built for speed, portability, and robust fallback handling across Debian/Ubuntu, macOS, Alpine, and Windows (WSL/Git Bash).

## ✨ Features
* **Zero-Touch Bootstrapper:** A single one-liner orchestrates repository cloning, tool installation, and symlinking based on your exact environment.
* **The Ultimate Editor:** A fully customized, transparent [LazyVim](https://github.com/LazyVim/LazyVim) setup featuring the Nordic theme, pre-configured for DevOps workflows (Terraform, Python, YAML, JSON).
* **Smart Environment Detection:** Automatically detects if you are running a GUI (Wayland/X11) or a headless container, stowing desktop apps (Kitty, Sway) only when necessary.
* **Graceful Degradation:** Safely falls back to a custom `link.sh` script on Windows Git Bash where GNU `stow` isn't natively available.
* **UAC Bypass:** Windows installations via `winget` are strictly scoped to the user profile, bypassing annoying admin prompts.

---

## 🚀 Installation & Setup

### Option 1: The One-Liner (Recommended)
If you are on a fresh machine, VM, or DevContainer, just run this to automatically clone the repo, install all tools, and link your configs in one shot:

```bash
curl -sL https://raw.githubusercontent.com/Aman1337g/dotfiles/main/setup | bash
````

### Option 2: Manual Installation

If you prefer to review the scripts before running them, you can bootstrap the system manually.

**1. Clone the Repository**

```bash
git clone [https://github.com/Aman1337g/dotfiles.git](https://github.com/Aman1337g/dotfiles.git) ~/.dotfiles
cd ~/.dotfiles
```

**2. Install Core Tools & Dependencies**
Runs the universal installer (detects `apt`, `apk`, `brew`, or `winget`) to grab dependencies like `eza`, `bat`, `fzf`, `zoxide`, `starship`, and `neovim`.

```bash
./install_tools
```

**3. Link the Configurations**

```bash
# Standard Linux / macOS / WSL (Requires GNU Stow)
stow bash scripts git nvim tmux starship fastfetch

# Alternative: Windows Git Bash Fallback (No Stow Required)
./link
```

> **Note on Windows Terminal/WSL:**
> Your `wsl/settings.json` should be placed in:
> `/mnt/c/Users/AMAN.GUPTA7/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState`

-----

## ❓ FAQs (GNU Stow Guide)

<details>
<summary><b>Q1 - What does "stow --adopt" do?</b></summary>

The `--adopt` option in `GNU Stow` handles existing files in the target directory that would conflict with symlinks Stow is trying to create. Instead of failing or overwriting, it moves those files into the Stow package directory—effectively “adopting” them.

### How it works

**Scenario**  
You already have `~/.bashrc`, and you want Stow to manage your Bash config. Normally, Stow would refuse to overwrite it.

**Using `--adopt`**

When you run:

```bash
cd ~/.dotfiles
stow --adopt bash
````

Stow will:

1. Move `~/.bashrc` → `~/.dotfiles/bash/.bashrc`
2. Create a symlink:
   `~/.bashrc` → `~/.dotfiles/bash/.bashrc`

This preserves your existing config while bringing it under Stow management.

</details>

<br>

<details>
<summary><b>Q2 - If I run "stow --adopt bash", will my existing .bashrc overwrite my desired config?</b></summary>

Yes. `stow --adopt` moves the existing file into your package directory, replacing whatever is already there. So your current system config will overwrite your repo version.

You’ll need to manually merge or restore your preferred configuration afterward.

### Suggested workflow

1. **Back up your current config**

   ```bash
   cp ~/.bashrc ~/.bashrc.bak
   ```

2. **Adopt existing file**

   ```bash
   cd ~/.dotfiles
   stow --adopt bash
   ```

3. **Restore or merge your desired config**

   ```bash
   cp ~/.bashrc.bak ~/.dotfiles/bash/.bashrc
   rm ~/.bashrc.bak
   stow -R bash
   ```

For more complex setups, consider using a diff/merge tool instead of overwriting.

</details>

<br>

<details>
<summary><b>Q3 - Why use "stow -R" if symlinks already reflect changes automatically?</b></summary>

You're right: if a symlink exists, editing the source file updates the target automatically. However, `stow -R` (restow) is useful in several situations:

### When to use `stow -R`

1. **Repository restructuring**
   If you move files or directories, restowing updates the symlinks.

2. **Fixing broken or missing symlinks**
   Recreates links that were deleted or corrupted.

3. **Adding new files**
   Ensures all files in the package are properly linked.

4. **Ensuring consistency**
   Rebuilds symlinks based on the current repo state.

### Command

```bash
cd ~/.dotfiles
stow -R bash
```

This removes existing symlinks and recreates them cleanly.

</details>

<br>

<details>
<summary><b>Q4 - What if I add a new file and run "stow" instead of "stow -R"?</b></summary>

Running `stow bash` (without `-R`) will still create symlinks for any **new files**.

### Behavior comparison

* **`stow bash`**

  * Creates symlinks only for files that don’t already have them
  * Leaves existing symlinks untouched

* **`stow -R bash`**

  * Removes all symlinks for the package
  * Recreates them from scratch

### Conclusion

* Use `stow` → when adding new files
* Use `stow -R` → when restructuring or fixing issues

In most cases, plain `stow` is sufficient.

</details>
