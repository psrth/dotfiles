#!/usr/bin/env bash
# macos preferences: only what differs from the defaults. run by setup.sh;
# safe to re-run. some changes need a log out/in to fully apply.
set -euo pipefail

# dock: auto-hide, 51px icons, no recent apps, minimize into app icon
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock tilesize -int 51
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock minimize-to-application -bool true
defaults write com.apple.dock mru-spaces -bool false  # don't reorder spaces

# hot corners: tl + br show desktop, tr notification center, bl display sleep
defaults write com.apple.dock wvous-tl-corner -int 4
defaults write com.apple.dock wvous-br-corner -int 4
defaults write com.apple.dock wvous-tr-corner -int 12
defaults write com.apple.dock wvous-bl-corner -int 10

# finder: list view, new windows open desktop, show drives on desktop
defaults write com.apple.finder FXPreferredViewStyle -string Nlsv
defaults write com.apple.finder NewWindowTarget -string PfDe
defaults write com.apple.finder NewWindowTargetPath -string "file://$HOME/Desktop/"
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

# trackpad: fast tracking, physical click (no tap), two-finger right click
defaults write NSGlobalDomain com.apple.trackpad.scaling -float 2.5
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool false
defaults write com.apple.AppleMultitouchTrackpad TrackpadRightClick -bool true

# desktop: clicking wallpaper doesn't reveal desktop; no tiled window margins
defaults write com.apple.WindowManager EnableStandardClickToShowDesktop -bool false
defaults write com.apple.WindowManager EnableTiledWindowMargins -bool false

killall Dock Finder 2>/dev/null || true
