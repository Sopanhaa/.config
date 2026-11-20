#!/usr/bin/env bash
# Bootstrap chezmoi and apply this dotfiles repository.
set -euo pipefail

REPO="${DOTFILES_REPO:-https://github.com/Sopanhaa/.config.git}"

if ! command -v chezmoi >/dev/null 2>&1; then
    echo "Installing chezmoi into $HOME/.local/bin ..."
    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
    export PATH="$HOME/.local/bin:$PATH"
fi

# Pull the latest source changes and apply them to $HOME
chezmoi init --apply "$REPO"

cat <<'EOF'

Done. Next steps:
  1. Install the font:     ./scripts/install-font.sh
  2. Install Fisher:       curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher
  3. Install fish plugins: fisher update
  4. Configure the prompt: tide configure
EOF
