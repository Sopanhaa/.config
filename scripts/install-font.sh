#!/usr/bin/env bash
# Install the BlexMono Nerd Font (IBMPlexMono Nerd Font) for the current user.
set -euo pipefail

RELEASE="IBMPlexMono"
URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${RELEASE}.zip"
DEST="${XDG_DATA_HOME:-$HOME/.local/share}/fonts/BlexMono"

for cmd in curl unzip; do
    command -v "$cmd" >/dev/null || {
        echo "error: $cmd is required" >&2
        exit 1
    }
done

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

echo "Downloading $URL"
curl -fL --progress-bar "$URL" -o "$tmp/font.zip"

mkdir -p "$DEST"
unzip -qo "$tmp/font.zip" -d "$DEST"

if command -v fc-cache >/dev/null; then
    fc-cache -f "$DEST" >/dev/null
fi

echo "Installed BlexMono Nerd Font into $DEST"
