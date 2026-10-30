#!/bin/bash
# Bootstrap a fresh Mac: Xcode CLT -> Homebrew -> chezmoi -> apply this repo.
# Usage: ~/dotfiles/install.sh
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! xcode-select -p >/dev/null 2>&1; then
  echo "==> Installing Xcode Command Line Tools (finish the dialog, then re-run this script)"
  xcode-select --install
  exit 0
fi

if [[ ! -x /opt/homebrew/bin/brew ]]; then
  echo "==> Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

command -v chezmoi >/dev/null || brew install chezmoi

echo "==> Applying dotfiles from $DOTFILES"
chezmoi init --apply --source "$DOTFILES"

echo
echo "Done. Next:"
echo "  1. Open 1Password, sign in, and turn on Settings > Developer > Use the SSH agent."
echo "  2. Log out and back in (keyboard repeat settings)."
echo "  3. Open a new Ghostty window."
