## Setting up dotfiles 

```bash
git clone https://github.com/Aman1337g/dotfiles.git

stow bash code git kitty starship tmux fonts
sudo stow --target=/etc/bash_completion.d etc-bash_completion.d
sudo stow --target=/etc etc-copy-paste-hang-sol
sudo sysctl -p  # to apply the etc-copy-paste-hang-sol change

```

> wsl/settings.json in /mnt/c/Users/AMAN.GUPTA7/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState

## FAQs

<details>
<summary>Q1 - What does "stow --adopt" do ?</summary>
<br>

The `--adopt` option in `GNU Stow` is used to handle existing files in the target directory that would conflict with the symbolic links `stow` is attempting to create. Instead of simply overwriting or reporting an error, `--adopt` moves these existing files into the `stow` package directory. This effectively "adopts" them into your stow-managed setup.

Here's how it works in practice:

### Scenario

Imagine you have a file `~/.bashrc` on your system, and you are trying to use `stow` to manage your `bash` configuration. Without `--adopt`, stow would refuse to create a link if a file with the same name already exists.

### Using `--adopt`

When you use the `--adopt` option, stow will:

1. Move the existing `~/.bashrc` file into your stow package directory (e.g., `~/.dotfiles/bash/.bashrc`).
2. Create a symbolic link from `~/.bashrc` to `~/.dotfiles/bash/.bashrc`.

### Example

1. **Initial Setup**: Let's say you have a `bash` configuration in your `~/.dotfiles` repository structured like this:
   ```
   ~/dotfiles/
   └── bash/
       └── .bashrc
   ```

2. **Existing File**: Assume there's already a `~/.bashrc` file on your system.

3. **Adopt the Existing File**: Run stow with the `--adopt` option:
   ```bash
   cd ~/.dotfiles
   stow --adopt bash
   ```

### What Happens

- The existing `~/.bashrc` file is moved to `~/.dotfiles/bash/.bashrc`.
- A symbolic link is created from `~/.bashrc` to `~/.dotfiles/bash/.bashrc`.

This way, you preserve your existing configuration and incorporate it into your stow-managed setup.

Using `--adopt` is particularly useful when you are starting to use `stow` with existing configuration files, allowing you to transition smoothly without losing any current settings.
</details>


<br>
<details>
<summary>Q2 - If I "stow --adopt bash" then existing .bashrc (let's say) will overwrite the configuration i want , then i have to copy the desired config back to the adopted .bashrc ?</summary>
<br>

Yes, that's correct. When you use the `stow --adopt` command, it moves the existing configuration files from their original locations (like `~/.bashrc`) into your `stow` package directory (like `~/.dotfiles/bash/.bashrc`). This effectively means the existing configuration will overwrite whatever is in your `stow` package directory. Therefore, after adopting, you will need to manually merge your desired configurations back into the adopted files if needed.

Here's a detailed workflow to handle this situation effectively:

### Workflow for Using `stow --adopt`

1. **Backup Existing Dotfiles**: Before adopting, it's a good idea to create a backup of your current dotfiles.
   ```bash
   cp ~/.bashrc ~/.bashrc.bak
   ```

2. **Adopt Existing Dotfiles**:
   ```bash
   cd ~/.dotfiles
   stow --adopt bash
   ```
   This will move `~/.bashrc` to `~/dotfiles/bash/.bashrc`.

3. **Overwrite desired changes**:
  ```bash
  cd ~/.dotfiles/bash/
  cat .bashrc.bak > .bashrc
  rm .bashrc.bak
  stow -R bash
  ```

### Handling Multiple Dotfiles

If you have multiple dotfiles to manage, repeat the above steps for each configuration file or directory.

### Summary

Using `stow --adopt` is a powerful way to incorporate existing configuration files into your `stow`-managed dotfiles setup, but it requires careful merging to ensure you don't lose your desired configurations. Always make backups before adopting and use appropriate tools to merge configurations efficiently.
</details>


<br>
<details>
<summary>Q3 - Why would I want to restow as if the file is symlinked and if I make some changes in ~/.dotfiles/bash/.bashrc it would be reflected back in the symlinked location ?</summary>
<br>

You're correct that if you have a symlink set up by `stow`, changes made to the file `.bashrc` in the `~/.dotfiles/bash/` directory will be reflected in the symlinked location. However, there are still valid reasons to use the `restow` command. Here are some scenarios where `restow` can be useful:

### Scenarios Where `restow` is Useful

1. **Reorganizing Your Dotfiles Repository**:
   If you move files within your dotfiles repository or change the structure of your dotfiles, you will need to restow to update the symlinks according to the new structure.

2. **Fixing Broken Symlinks**:
   If any symlinks are accidentally broken or removed, `restow` can recreate them correctly.

3. **Adding New Dotfiles**:
   If you add new files to a package in your dotfiles repository, running `restow` will create the necessary symlinks for these new files.

4. **Updating Configurations**:
   If you modify the structure or content of your dotfiles significantly, `restow` ensures all links are updated according to the latest changes.

### How to Restow

To restow a package, you simply use the `-R` or `--restow` option with `stow`:

```bash
cd ~/.dotfiles
stow -R bash
```

This command will:

- Remove the existing symlinks.
- Create new symlinks based on the current contents of the `bash` directory.

### Example

Suppose your `~/.dotfiles` directory looks like this:

```
~/.dotfiles/
├── bash/
│   ├── .bashrc
│   └── .bash_profile
└── tmux/
    └── .tmux.conf
```

If you make changes like adding `.bash_aliases` to the `bash` directory:

1. **Add New File**:
   ```bash
   echo "alias ll='ls -la'" > ~/.dotfiles/bash/.bash_aliases
   ```

2. **Restow to Update Symlinks**:
   ```bash
   cd ~/.dotfiles
   stow -R bash
   ```

This will ensure that `.bash_aliases` is also symlinked in your home directory.

### Restow Summary

In summary, `restow` is used to update the symlinks when:

- You reorganize the dotfiles repository.
- Symlinks are broken or missing.
- You add new files to a package.
- You make significant changes that require re-linking.

By using `restow`, you maintain consistency between your dotfiles repository and the symlinks in your home directory.
</details>


<br>
<details>
<summary>Q4 - What if I added a new file in "~/.dotfiles/bash/" and use stow instead of stow -R ?
</summary>
<br>

Using `stow` without the `-R` option after adding new files to your dotfiles repository will still create the necessary symlinks for those new files. The `-R` (or `--restow`) option is primarily useful when you need to recreate all the symlinks, not just add new ones.

Here's how it works:

### Scenario: Adding a New File

Assume you have a `~/.dotfiles/` directory structured like this:

```
~/.dotfiles/
├── bash/
│   ├── .bashrc
│   └── .bash_profile
└── tmux/
    └── .tmux.conf
```

You add a new file to the `bash` directory:

1. **Add a New File**:
   ```bash
   echo "alias ll='ls -la'" > ~/.dotfiles/bash/.bash_aliases
   ```

### Using `stow` vs `stow -R`

#### Using `stow`

Running `stow bash` will create symlinks only for the files that do not already have symlinks in the target directory (e.g., your home directory).

```bash
cd ~/.dotfiles
stow bash
```

- This will create a symlink for `.bash_aliases` in your home directory if it doesn't already exist.
- Existing symlinks for `.bashrc` and `.bash_profile` will remain unchanged.

#### Using `stow -R`

Running `stow -R bash` will remove existing symlinks and then create new symlinks for all files in the `bash` directory.

```bash
cd ~/.dotfiles
stow -R bash
```

- This will ensure all files in the `~/.dotfiles/bash/` directory are correctly symlinked.
- Any changes in the structure or any updates to the symlinks will be handled.

### Practical Example

1. **Original Setup**:
   ```bash
   cd ~/.dotfiles
   stow bash
   ```
   This creates symlinks:
   ```
   ~/.bashrc -> ~/.dotfiles/bash/.bashrc
   ~/.bash_profile -> ~/.dotfiles/bash/.bash_profile
   ```

2. **Add New File**:
   ```bash
   echo "alias ll='ls -la'" > ~/.dotfiles/bash/.bash_aliases
   ```

3. **Using `stow bash`**:
   ```bash
   cd ~/.dotfiles
   stow bash
   ```
   This adds the new symlink:
   ```
   ~/.bash_aliases -> ~/.dotfiles/bash/.bash_aliases
   ```

4. **Using `stow -R bash`**:
   ```bash
   cd ~/dotfiles
   stow -R bash
   ```
   This recreates all symlinks:
   ```
   ~/.bashrc -> ~/.dotfiles/bash/.bashrc
   ~/.bash_profile -> ~/.dotfiles/bash/.bash_profile
   ~/.bash_aliases -> ~/.dotfiles/bash/.bash_aliases
   ```

### Conclusion

- **Use `stow`**: When you add new files to your ~/.dotfiles repository and want to create symlinks for these new files without modifying existing symlinks.
- **Use `stow -R`**: When you want to recreate all symlinks, useful if you have restructured your dotfiles or need to fix existing symlinks.

In most cases, running `stow` is sufficient for adding new files. Use `stow -R` for a more thorough refresh of your symlinks.
</details>
