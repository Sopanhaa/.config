#!/usr/bin/env bash
# Link this repository's config/ directory into ~/.config.
# Existing entries are backed up as <name>.bak.<timestamp>.
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE="$DOTFILES/config"
TARGET="${XDG_CONFIG_HOME:-$HOME/.config}"
STAMP="$(date +%Y%m%d-%H%M%S)"

if [[ ! -d "$SOURCE" ]]; then
    echo "error: $SOURCE not found" >&2
    exit 1
fi

mkdir -p "$TARGET"

for src in "$SOURCE"/*; do
    name="$(basename "$src")"
    dest="$TARGET/$name"

    if [[ -L "$dest" && "$(readlink -f "$dest")" == "$(readlink -f "$src")" ]]; then
        printf 'ok      %s\n' "$dest"
        continue
    fi

    if [[ -e "$dest" || -L "$dest" ]]; then
        mv "$dest" "$dest.bak.$STAMP"
        printf 'backup  %s -> %s\n' "$dest" "$dest.bak.$STAMP"
    fi

    ln -s "$src" "$dest"
    printf 'link    %s -> %s\n' "$dest" "$src"
done

cat <<'EOF'

Done. Next steps:
  1. Install the font:     ./scripts/install-font.sh
  2. Install Fisher:       curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher
  3. Install fish plugins: fisher update
  4. Configure the prompt: tide configure
EOF
