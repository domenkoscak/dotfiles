# dotfiles

My macOS setup, managed with [chezmoi](https://chezmoi.io). The repo lives at `~/dotfiles`
and on GitHub at `domenkoscak/dotfiles` (private).

- [New Mac](#new-mac) — from a fresh macOS to a fully set up machine
- [Existing Mac](#existing-mac-first-time) — switching a Mac that's already in use
- [Day to day](#day-to-day) — updating, adding apps, changing settings
- [Rolling back](#rolling-back)
- [Layout](#layout)

---

## New Mac

Takes about 30–60 minutes, mostly downloads (Xcode alone is ~10 GB).

### 1. Before you start

- Finish macOS setup and sign in with your Apple ID.
- Open the **App Store** and sign in (needed for Xcode, Transporter, DevCleaner, Numbers).
- Run Software Update so macOS is current.

### 2. Get the repo

The repo is private, so you need to log in to GitHub. Easiest is the GitHub CLI:

```bash
xcode-select --install
```

Wait for the Command Line Tools dialog to finish, then install Homebrew:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

```bash
eval "$(/opt/homebrew/bin/brew shellenv)" && brew install gh && gh auth login
```

Pick **GitHub.com → HTTPS → Login with a web browser**. Then clone:

```bash
gh repo clone domenkoscak/dotfiles ~/dotfiles
```

### 3. Run the installer

```bash
~/dotfiles/install.sh
```

What happens, in order:

1. chezmoi asks **"Computer name"**: press Enter for `Lojze`, or type another name
   (e.g. `Kosobrin` on the server). Asked once per machine.
2. **Homebrew installs everything** in the `Brewfile`: CLI tools, apps, fonts, App Store apps.
   This is the long part.
3. Dotfiles are written to `~` (zsh, Starship, Ghostty, git, SSH, mise, VS Code).
4. **mise** installs Node LTS, pnpm, bun, Python and uv.
5. **VS Code extensions** install.
6. **`macos.sh`** applies system settings. It asks for your **password** (computer name,
   Touch ID for sudo, power settings).

Things macOS will pop up — say yes:

- "Terminal wants to control System Events": needed for dark mode and login items.
- "Change default browser to Dia?": click **Use Dia**.

If anything fails halfway, fix the cause and run `chezmoi apply` — it picks up where it left off.

### 4. After the installer

1. **1Password**: open it, sign in, then **Settings → Developer → Use the SSH agent**.
   Until then, git commits can't be signed and `git push` over SSH won't work.
2. Test it:

   ```bash
   ssh -T git@github.com
   ```

   It should greet you by username.
3. Switch the repo to SSH so pushes use 1Password from now on:

   ```bash
   git -C ~/dotfiles remote set-url origin git@github.com:domenkoscak/dotfiles.git
   ```

4. **Log out and back in** (keyboard repeat and some Finder settings need it).
5. **Ghostty**: open it, press **Ctrl+`** once and allow Accessibility so the quick terminal works.
6. **Raycast**: open it and set its hotkey to **Cmd+Space** (Spotlight's shortcut is already freed).
7. Open the apps that need a login: Figma, Discord, Claude, Logi Options+, Stats, Bambu Studio, OrbStack.

Done.

---

## Existing Mac (first time)

For a Mac that's already in use (like Lojze before switching). chezmoi **overwrites** files
and doesn't keep copies, so back up first:

```bash
mkdir -p ~/dotfiles-backup && cp -R ~/.zshrc ~/.zprofile ~/.config/starship.toml ~/.config/ghostty ~/.config/git ~/.ssh/config "$HOME/Library/Application Support/Code/User/settings.json" ~/dotfiles-backup/
```

Point chezmoi at the repo (asks for the computer name):

```bash
chezmoi init --source ~/dotfiles
```

See what would change (`q` to quit):

```bash
chezmoi diff
```

Close VS Code, then apply:

```bash
chezmoi apply
```

Then do the [After the installer](#4-after-the-installer) steps that aren't done yet.

Watch out for:

- **Node/Python switch to mise.** Projects that need a specific Node version should have a
  `.nvmrc` or `mise.toml`. Global npm packages installed with Homebrew's Node aren't visible anymore.
- **Git email** becomes `domen.koscak@zerodays.dev` everywhere except `~/Documents/Personal`.

---

## Day to day

| Command             | What it does                                                         |
| ------------------- | -------------------------------------------------------------------- |
| `upgrade`           | Pull the repo + apply, then upgrade brew, mise tools and App Store apps |
| `dotfiles`          | `cd ~/dotfiles`                                                      |
| `chezmoi diff`      | Show what `apply` would change                                       |
| `chezmoi apply`     | Write the repo's files into `~` and rerun scripts whose inputs changed |
| `chezmoi edit ~/.zshrc` | Edit the repo copy of a file (then `chezmoi apply`)              |
| `chezmoi re-add`    | You edited a file in `~` directly? This copies it back into the repo |
| `cleanup`           | Free disk space (brew, mise, Xcode DerivedData, pnpm store)          |

### Changing something

1. Edit in `~/dotfiles` (see [Layout](#layout) for where things are).
2. `chezmoi apply`.
3. Commit and push:

   ```bash
   git -C ~/dotfiles add -A && git -C ~/dotfiles commit -m "Describe the change" && git -C ~/dotfiles push
   ```

4. On your other Macs: `upgrade` (or just `chezmoi update`).

### Common changes

- **Add an app or CLI tool**: add a `cask "name"` / `brew "name"` line to `Brewfile`
  (find names with `brew search name`), then `chezmoi apply`.
- **Remove an app**: delete its line, then `brew uninstall --cask name`.
  (`brew bundle` only installs, it never removes.)
- **Add a VS Code extension**: add its ID to `vscode-extensions.txt`
  (right-click the extension in VS Code → Copy Extension ID).
- **Change a macOS setting**: edit `macos.sh`; it reruns on the next `chezmoi apply`.
- **Different Node/Python version globally**: edit `home/dot_config/mise/config.toml`
  (e.g. `node = "24"`). Per project: `mise use node@22` inside the project.
- **New alias or function**: `home/dot_zshrc`, then `chezmoi apply && exec zsh`.

---

## Rolling back

- One file: `cp ~/dotfiles-backup/<file> <original path>`.
- An earlier version of the repo: `git -C ~/dotfiles log`, then
  `git -C ~/dotfiles checkout <commit> -- <path>` and `chezmoi apply`.
- macOS settings: there's no undo script; change them back in System Settings.

---

## Layout

```
Brewfile                 Homebrew formulae, casks, App Store apps
vscode-extensions.txt    VS Code extensions
macos.sh                 System settings (Dock, Finder, keyboard, power, name, login items)
install.sh               Bootstrap for a fresh Mac
home/                    Everything chezmoi puts in ~ (see .chezmoiroot)
  .chezmoi.toml.tmpl               chezmoi config; asks for the computer name
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

The `run_onchange_*` scripts rerun automatically when `Brewfile`, `vscode-extensions.txt`,
`macos.sh`, the mise config or the computer name change.
