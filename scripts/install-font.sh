#!/usr/bin/env bash
#
# Install the BlexMono Nerd Font (IBMPlexMono Nerd Font) for the current user.
#
#   ./scripts/install-font.sh           install if missing
#   ./scripts/install-font.sh --check   report whether it is installed
set -euo pipefail

FONT_FAMILY="BlexMono Nerd Font"
RELEASE="IBMPlexMono"
URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${RELEASE}.zip"
DEST="${XDG_DATA_HOME:-$HOME/.local/share}/fonts/BlexMono"

MODE="install"

say() { printf '%s\n' "$*"; }
step() { printf '\n==> %s\n' "$*"; }
ok() { printf '  ok  %s\n' "$*"; }
warn() { printf '  !   %s\n' "$*" >&2; }
die() {
    printf '  x   %s\n' "$*" >&2
    exit 1
}

usage() {
    cat <<'EOF'
Install the BlexMono Nerd Font for the current user.

Usage:
  ./scripts/install-font.sh           install if missing
  ./scripts/install-font.sh --check   report whether it is installed
EOF
}

font_installed() {
    command -v fc-list >/dev/null 2>&1 || return 1
    local families
    families="$(fc-list : family 2>/dev/null)" || return 1
    grep -Fqi "$FONT_FAMILY" <<<"$families"
}

while (($# > 0)); do
    case "$1" in
        --check) MODE="check" ;;
        -h | --help)
            usage
            exit 0
            ;;
        *)
            usage >&2
            die "Unknown option: $1"
            ;;
    esac
    shift
done

if ((EUID == 0)) && [[ -n "${SUDO_USER:-}" ]]; then
    die "Do not run this script with sudo. It installs fonts for the current user only."
fi

if [[ "$MODE" == "check" ]]; then
    if font_installed; then
        ok "$FONT_FAMILY is installed."
        exit 0
    fi
    warn "$FONT_FAMILY is not installed."
    exit 1
fi

if font_installed; then
    ok "$FONT_FAMILY is already installed."
    exit 0
fi

command -v fc-cache >/dev/null 2>&1 ||
    die "fontconfig is required. Install it with: sudo apt-get install fontconfig"
command -v unzip >/dev/null 2>&1 ||
    die "unzip is required. Install it with: sudo apt-get install unzip"

if command -v curl >/dev/null 2>&1; then
    DOWNLOADER="curl"
elif command -v wget >/dev/null 2>&1; then
    DOWNLOADER="wget"
else
    die "curl or wget is required to download the font."
fi

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
archive="$tmp/${RELEASE}.zip"

step "Downloading $FONT_FAMILY"
say "$URL"
if [[ "$DOWNLOADER" == "curl" ]]; then
    if ! curl -fL --progress-bar "$URL" -o "$archive"; then
        die "Download failed. Check your network connection."
    fi
else
    if ! wget -q --show-progress -O "$archive" "$URL"; then
        die "Download failed. Check your network connection."
    fi
fi

step "Extracting to $DEST"
mkdir -p "$DEST"
if ! unzip -qo "$archive" -d "$DEST"; then
    die "Could not extract $archive."
fi

if ! fc-cache -f "$DEST" >/dev/null 2>&1; then
    warn "fc-cache reported an error; the font may still work."
fi

if ! font_installed; then
    die "Font files were written to $DEST, but fc-list does not detect '$FONT_FAMILY'."
fi

ok "$FONT_FAMILY installed and detected."
