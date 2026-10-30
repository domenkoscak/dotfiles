#!/bin/bash
# macOS system preferences. Safe to re-run; `chezmoi apply` runs it whenever it changes.
set -euo pipefail

# Close System Settings so it doesn't overwrite what we set.
osascript -e 'tell application "System Settings" to quit' 2>/dev/null || true

# ---- Dock ----------------------------------------------------------------
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0          # appear instantly
defaults write com.apple.dock tilesize -int 40
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock mru-spaces -bool false          # keep Spaces in order

# Dock apps, left to right.
if command -v dockutil >/dev/null; then
  dockutil --remove all --no-restart
  for app in \
    "/Applications/Dia.app" \
    "/Applications/Ghostty.app" \
    "/Applications/Visual Studio Code.app" \
    "/Applications/Claude.app" \
    "/Applications/Figma.app" \
    "/Applications/Discord.app"; do
    [[ -d "$app" ]] && dockutil --add "$app" --no-restart
  done
fi

# ---- Finder --------------------------------------------------------------
defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"   # list view
defaults write com.apple.finder _FXSortFoldersFirst -bool true
defaults write com.apple.finder NewWindowTarget -string "PfHm"        # new window = Home
defaults write com.apple.finder NewWindowTargetPath -string "file://$HOME/"
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# ---- Keyboard & text -----------------------------------------------------
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false     # hold = repeat
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain WebAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write NSGlobalDomain AppleKeyboardUIMode -int 2               # Tab through all controls

# ---- Screenshots ---------------------------------------------------------
mkdir -p "$HOME/Screenshots"
defaults write com.apple.screencapture location -string "$HOME/Screenshots"
defaults write com.apple.screencapture type -string "png"
defaults write com.apple.screencapture disable-shadow -bool true

# ---- Apply ---------------------------------------------------------------
killall Dock Finder SystemUIServer 2>/dev/null || true
echo "macOS settings applied. Key repeat changes need a log out / log in."
