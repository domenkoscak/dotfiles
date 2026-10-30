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

# ---- Animations & desktop ------------------------------------------------
defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false  # no zoom on new windows
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001
defaults write com.apple.dock expose-animation-duration -float 0.1            # Mission Control
defaults write com.apple.dock autohide-time-modifier -float 0.3               # Dock slide
defaults write com.apple.WindowManager EnableStandardClickToShowDesktop -bool false

# ---- Menu bar ------------------------------------------------------------
defaults -currentHost write com.apple.controlcenter BatteryShowPercentage -bool true
defaults -currentHost write com.apple.Spotlight MenuItemHidden -int 1

# ---- Free Cmd+Space for Raycast (set the hotkey in Raycast itself) -------
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 64 \
  "<dict><key>enabled</key><false/><key>value</key><dict><key>parameters</key><array><integer>32</integer><integer>49</integer><integer>1048576</integer></array><key>type</key><string>standard</string></dict></dict>"
/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u 2>/dev/null || true

# ---- Save dialogs --------------------------------------------------------
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false   # save to disk
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

# ---- Touch ID for sudo (asks for your password once) ---------------------
if ! grep -qs pam_tid.so /etc/pam.d/sudo_local; then
  echo "auth       sufficient     pam_tid.so" | sudo tee /etc/pam.d/sudo_local >/dev/null
fi

# ---- Screenshots ---------------------------------------------------------
mkdir -p "$HOME/Screenshots"
defaults write com.apple.screencapture location -string "$HOME/Screenshots"
defaults write com.apple.screencapture type -string "png"
defaults write com.apple.screencapture disable-shadow -bool true

# ---- Apply ---------------------------------------------------------------
killall Dock Finder SystemUIServer ControlCenter 2>/dev/null || true
echo "macOS settings applied. Key repeat changes need a log out / log in."
