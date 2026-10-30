# dotfiles

My macOS setup, managed with [chezmoi](https://chezmoi.io). The repo lives at `~/dotfiles`.

## New Mac

1. Sign in to the App Store (needed for Xcode, Transporter, DevCleaner, Numbers).
2. Clone and run:

   ```bash
   xcode-select --install   # if git isn't available yet
   git clone https://github.com/domenkoscak/dotfiles.git ~/dotfiles
   ~/dotfiles/install.sh
   ```

3. In 1Password: sign in, then **Settings → Developer → Use the SSH agent**. Git signing and GitHub SSH go through it.
4. Log out and back in.

## Day to day

| Command      | What it does                                                       |
| ------------ | ------------------------------------------------------------------ |
| `dotfiles`   | `cd ~/dotfiles`                                                    |
| `upgrade`    | Pull this repo and apply it, then update brew, mise and App Store apps |
| `chezmoi apply` | Copy the repo's files into `~` and run any changed scripts     |
| `chezmoi diff`  | Show what `apply` would change                                 |
| `chezmoi re-add` | Pull edits you made to files in `~` back into the repo        |

Edit files in `~/dotfiles/home`, then `chezmoi apply`. Or edit in place with `chezmoi edit ~/.zshrc`.

## Layout

```
Brewfile                 Homebrew formulae, casks, App Store apps
vscode-extensions.txt    VS Code extensions
macos.sh                 System preferences (Dock, Finder, keyboard, screenshots)
install.sh               Bootstrap for a fresh Mac
home/                    Everything chezmoi puts in ~ (see .chezmoiroot)
  dot_zshrc, dot_zprofile          zsh
  dot_config/starship.toml         prompt
  dot_config/ghostty/config        terminal
  dot_config/git/                  git (work email default, personal under ~/Documents/Personal)
  dot_config/mise/config.toml      node, pnpm, bun, python, uv
  private_dot_ssh/                 SSH config for the 1Password agent (public key only)
  Library/.../Code/User/settings.json   VS Code
  .chezmoiexternal.toml            fzf-tab plugin, bat Tokyo Night theme
  run_*                            scripts: brew bundle, mise install, VS Code extensions, macos.sh
```

The `run_onchange_*` scripts rerun automatically when `Brewfile`, `vscode-extensions.txt`, `macos.sh` or the mise config change.
