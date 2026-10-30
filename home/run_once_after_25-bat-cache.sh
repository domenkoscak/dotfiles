#!/bin/bash
# Register the Tokyo Night bat theme downloaded via .chezmoiexternal.toml.
set -euo pipefail
eval "$(/opt/homebrew/bin/brew shellenv)"
bat cache --build
