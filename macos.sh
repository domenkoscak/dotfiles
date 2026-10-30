#!/bin/bash
# macOS system preferences. Safe to re-run; `chezmoi apply` runs it whenever it changes.
set -euo pipefail

# Close System Settings so it doesn't overwrite what we set.
osascript -e 'tell application "System Settings" to quit' 2>/dev/null || true

# ---- Computer name (passed in by chezmoi; e.g. Lojze, Kosobrin) ----------
if [[ -n "${COMPUTER_NAME:-}" && "$(scutil --get ComputerName)" != "$COMPUTER_NAME" ]]; then
  host=$(printf '%s' "$COMPUTER_NAME" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9' '-')
  sudo scutil --set ComputerName "$COMPUTER_NAME"
  sudo scutil --set HostName "$host"
  sudo scutil --set LocalHostName "$host"
fi

# ---- Appearance ----------------------------------------------------------
osascript -e 'tell application "System Events" to tell appearance preferences to set dark mode to true'

# ---- Default browser (macOS shows a confirmation dialog once) ------------
if command -v defaultbrowser >/dev/null && [[ -d /Applications/Dia.app ]] \
   && ! defaultbrowser | grep -q '^\* dia$'; then
  defaultbrowser dia
fi

# ---- Login items ---------------------------------------------------------
# Ghostty stays running so its Ctrl+` quick terminal works from anywhere.
for app in Raycast Shottr 1Password logioptionsplus OrbStack Stats Ghostty; do
  [[ -d "/Applications/$app.app" ]] || continue
  osascript <<EOF
tell application "System Events"
  if not (exists login item "$app") then
    make login item at end with properties {path:"/Applications/$app.app", hidden:true}
  end if
end tell
EOF
done

# ---- Dock ----------------------------------------------------------------
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0          # appear instantly
defaults write com.apple.dock tilesize -int 40
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock mru-spaces -bool false          # keep Spaces in order
defaults write com.apple.dock showhidden -bool true           # dim icons of Cmd+H'd apps
defaults write com.apple.dock minimize-to-application -bool true
defaults write com.apple.dock scroll-to-open -bool true       # scroll up on an icon = its windows
defaults write com.apple.dock enterMissionControlByTopWindowDrag -bool false

# Dock apps, left to right.
if command -v dockutil >/dev/null; then
  dockutil --remove all --no-restart
  for app in \
    "/Applications/Dia.app" \
    "/Applications/Slack.app" \
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
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"     # search current folder
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true    # full path in title
defaults write NSGlobalDomain com.apple.springing.enabled -bool true   # drag onto a folder opens it
defaults write NSGlobalDomain com.apple.springing.delay -float 0.1     # ...after 0.1s (default 0.5)
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false
chflags nohidden "$HOME/Library"
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

# ---- Trackpad & windows (need a log out / log in) ------------------------
# Three-finger drag; three-finger swipes move to four fingers, like System Settings does.
for domain in com.apple.AppleMultitouchTrackpad com.apple.driver.AppleBluetoothMultitouch.trackpad; do
  defaults write "$domain" TrackpadThreeFingerDrag -bool true
  defaults write "$domain" TrackpadThreeFingerHorizSwipeGesture -int 0
  defaults write "$domain" TrackpadThreeFingerVertSwipeGesture -int 0
  defaults write "$domain" TrackpadFourFingerHorizSwipeGesture -int 2
  defaults write "$domain" TrackpadFourFingerVertSwipeGesture -int 2
done
defaults write NSGlobalDomain NSWindowShouldDragOnGesture -bool true   # Ctrl+Cmd+drag moves windows
defaults write NSGlobalDomain NSToolbarTitleViewRolloverDelay -float 0 # title-bar icon shows at once

# ---- Animations & desktop ------------------------------------------------
defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false  # no zoom on new windows
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001
defaults write com.apple.dock expose-animation-duration -float 0.1            # Mission Control
defaults write com.apple.dock autohide-time-modifier -float 0.3               # Dock slide
defaults write com.apple.WindowManager EnableStandardClickToShowDesktop -bool false

# ---- Menu bar ------------------------------------------------------------
defaults -currentHost write com.apple.controlcenter BatteryShowPercentage -bool true
defaults -currentHost write com.apple.Spotlight MenuItemHidden -int 1
defaults -currentHost write NSGlobalDomain NSStatusItemSpacing -int 8          # tighter icons (default 16)
defaults -currentHost write NSGlobalDomain NSStatusItemSelectionPadding -int 6

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

# ---- Apps ----------------------------------------------------------------
defaults write com.apple.ActivityMonitor ShowCategory -int 0          # all processes
defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
defaults write com.apple.ActivityMonitor SortDirection -int 0
defaults write com.apple.ActivityMonitor IconType -int 5              # CPU graph in Dock icon
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true  # Photos stays shut on plug-in
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true
defaults write com.apple.CrashReporter UseUNC -int 1                  # crashes as notifications

# ---- Keep Xcode build junk out of Spotlight ------------------------------
# Spotlight skips any folder ending in .noindex.
defaults write com.apple.dt.Xcode IDECustomDerivedDataLocation -string "$HOME/Library/Developer/Xcode/DerivedData.noindex"

# ---- Power: on the charger the display sleeps, the Mac doesn't ----------
sudo pmset -c sleep 0 displaysleep 10

# ---- Touch ID for sudo (asks for your password once) ---------------------
if ! grep -qs pam_tid.so /etc/pam.d/sudo_local; then
  echo "auth       sufficient     pam_tid.so" | sudo tee /etc/pam.d/sudo_local >/dev/null
fi

# ---- Screenshots ---------------------------------------------------------
mkdir -p "$HOME/Screenshots"
defaults write com.apple.screencapture location -string "$HOME/Screenshots"
defaults write com.apple.screencapture type -string "png"
defaults write com.apple.screencapture disable-shadow -bool true
defaults write com.apple.screencapture show-thumbnail -bool false   # save right away, no preview
defaults write com.apple.screencapture name -string "${COMPUTER_NAME:-$(scutil --get ComputerName)}"  # "Lojze 2026-10-30 at…"

# ---- Apply ---------------------------------------------------------------
killall Dock Finder SystemUIServer ControlCenter 2>/dev/null || true
echo "macOS settings applied. Keyboard, trackpad and menu bar changes need a log out / log in."
