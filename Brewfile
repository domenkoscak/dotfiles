# Everything Homebrew installs. Applied by `chezmoi apply` whenever this file changes.
# Languages (node, python, pnpm, bun, uv) come from mise, not brew.

tap "infisical/get-cli"

# ---- Shell & dotfiles ----------------------------------------------------
brew "git"
brew "chezmoi"
brew "mise"
brew "uv"         # here, not in mise, so GUI apps and MCP servers find uvx
brew "starship"
brew "zsh-autosuggestions"
brew "zsh-syntax-highlighting"
brew "eza"
brew "bat"
brew "zoxide"
brew "fzf"
brew "fd"
brew "ripgrep"
brew "mas"        # App Store CLI
brew "dockutil"   # used by macos.sh to set the Dock
brew "defaultbrowser"  # used by macos.sh to make Dia the default

# ---- Dev CLI -------------------------------------------------------------
brew "gh"
brew "jq"
brew "tree"
brew "wget"
brew "awscli"
brew "infisical/get-cli/infisical"
brew "cloudflared"
brew "ffmpeg"
brew "mole"       # Mac cleaner
brew "btop"       # process monitor
brew "dust"       # disk usage by folder
brew "duf"        # disk free overview
brew "libpq"      # psql (keg-only, put on PATH in .zprofile)

# ---- iOS -----------------------------------------------------------------
brew "cocoapods"
brew "fastlane"

# ---- Android -------------------------------------------------------------
brew "openjdk@21"
brew "bundletool"
cask "android-commandlinetools"
cask "android-platform-tools"

# ---- Fonts ---------------------------------------------------------------
cask "font-jetbrains-mono-nerd-font"

# ---- Apps ----------------------------------------------------------------
cask "1password"
cask "ghostty"
cask "visual-studio-code"
cask "orbstack"
cask "claude"
cask "claude-code@latest"
cask "figma"
cask "thebrowsercompany-dia"
cask "google-chrome"
cask "firefox"
cask "raycast"
cask "shottr"
cask "stats"          # CPU/RAM/network in the menu bar
cask "bambu-studio"   # slicer for Bine (Bambu Lab X2D)
cask "freecad"        # CAD; Claude drives it through the FreeCAD MCP addon
cask "discord"
cask "slack"
cask "vlc"
cask "logi-options+"

# ---- App Store (sign in to the App Store first) -------------------------
mas "Xcode", id: 497799835
mas "Transporter", id: 1450874784
mas "DevCleaner", id: 1388020431
mas "Numbers", id: 361304891
