#!/usr/bin/env bash
#
# Minimal dotfiles installer for Debian, Ubuntu, and Kubuntu.
#
#   ./install.sh             install everything (asks before touching configs)
#   ./install.sh --dry-run   show what would be installed
#   ./install.sh --yes       skip the confirmation prompt
#
set -euo pipefail

REPO_URL="${DOTFILES_REPO:-https://github.com/Sopanhaa/.config.git}"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_BIN="$HOME/.local/bin"
BACKUP_ROOT="$HOME/.dotfiles-backup"
FONT_FAMILY="BlexMono Nerd Font"

ASSUME_YES=0
DRY_RUN=0
APT_UPDATED=0
LAST_BACKUP=""

if [[ -t 1 ]]; then
    C_RESET=$'\033[0m'
    C_BLUE=$'\033[34m'
    C_GREEN=$'\033[32m'
    C_YELLOW=$'\033[33m'
    C_RED=$'\033[31m'
else
    C_RESET="" C_BLUE="" C_GREEN="" C_YELLOW="" C_RED=""
fi

say() { printf '%s\n' "$*"; }
step() { printf '\n%s==>%s %s\n' "$C_BLUE" "$C_RESET" "$*"; }
ok() { printf '%s  ok%s  %s\n' "$C_GREEN" "$C_RESET" "$*"; }
warn() { printf '%s  !%s   %s\n' "$C_YELLOW" "$C_RESET" "$*"; }
die() {
    printf '%s  x%s   %s\n' "$C_RED" "$C_RESET" "$*" >&2
    exit 1
}

trap 'rc=$?; (( rc == 0 )) || printf "\nerror: command failed (exit %d): %s\n" "$rc" "$BASH_COMMAND" >&2' ERR

usage() {
    cat <<'EOF'
Minimal dotfiles installer for Debian, Ubuntu, and Kubuntu.

Usage:
  ./install.sh             install tools and apply dotfiles
  ./install.sh --dry-run   show what would be done
  ./install.sh --yes       skip the confirmation prompt
  ./install.sh --help      show this help
EOF
}

have() { command -v "$1" >/dev/null 2>&1; }

add_local_bin() {
    case ":$PATH:" in
        *":$LOCAL_BIN:"*) ;;
        *) export PATH="$LOCAL_BIN:$PATH" ;;
    esac
}

detect_os() {
    [[ -r /etc/os-release ]] || die "Cannot detect the operating system."
    # shellcheck disable=SC1091
    . /etc/os-release
    OS_NAME="${PRETTY_NAME:-Linux}"
    case " ${ID:-} ${ID_LIKE:-} " in
        *" debian "* | *" ubuntu "*) ;;
        *) die "Unsupported system: $OS_NAME. Use Debian, Ubuntu, or Kubuntu." ;;
    esac
    have apt-get || die "apt-get is required."
}

detect_arch() {
    case "$(uname -m)" in
        x86_64) EZA_ARCH="x86_64" GHQ_ARCH="amd64" LAZYGIT_ARCH="x86_64" ;;
        aarch64 | arm64) EZA_ARCH="aarch64" GHQ_ARCH="arm64" LAZYGIT_ARCH="arm64" ;;
        *) die "Unsupported CPU architecture: $(uname -m)" ;;
    esac
}

run_privileged() {
    if (( EUID == 0 )); then
        "$@"
    elif have sudo; then
        sudo "$@"
    else
        die "Root access is required for: $*"
    fi
}

apt_update() {
    (( APT_UPDATED )) && return 0
    run_privileged apt-get update -qq ||
        die "apt-get update failed. Check your network connection and apt sources."
    APT_UPDATED=1
}

apt_install() {
    (($# > 0)) || return 0
    apt_update
    run_privileged env DEBIAN_FRONTEND=noninteractive apt-get install -y "$@" ||
        die "Package installation failed: $*"
}

apt_has() { apt-cache show "$1" >/dev/null 2>&1; }

download() {
    curl -fsSL --retry 2 "$1" -o "$2" || die "Download failed: $1"
}

install_archive_binary() {
    local url="$1" name="$2" type="$3"
    local tmp archive binary

    tmp="$(mktemp -d)"
    archive="$tmp/archive"

    step "Installing $name into $LOCAL_BIN"
    download "$url" "$archive"
    case "$type" in
        zip) unzip -qo "$archive" -d "$tmp" || die "Could not extract $name." ;;
        tar) tar -xzf "$archive" -C "$tmp" || die "Could not extract $name." ;;
        *) die "Unknown archive type: $type" ;;
    esac

    binary="$(find "$tmp" -type f -name "$name" -print -quit)"
    [[ -n "$binary" ]] || die "Could not find the $name binary in the archive."
    mkdir -p "$LOCAL_BIN"
    install -m 0755 "$binary" "$LOCAL_BIN/$name"
    rm -rf "$tmp"
    hash -r
    ok "$name installed."
}

install_base_packages() {
    local packages=() cmd pkg
    for cmd in curl git unzip fc-cache fc-list; do
        have "$cmd" && continue
        case "$cmd" in
            curl | git | unzip) pkg="$cmd" ;;
            *) pkg="fontconfig" ;;
        esac
        [[ " ${packages[*]:-} " == *" $pkg "* ]] || packages+=("$pkg")
    done
    [[ -e /etc/ssl/certs/ca-certificates.crt ]] || packages+=("ca-certificates")

    if ((${#packages[@]} > 0)); then
        step "Installing base packages: ${packages[*]}"
        apt_install "${packages[@]}"
        ok "Base packages installed."
    else
        ok "Base packages are already installed."
    fi
}

install_cli_tools() {
    local cmd pkg
    local packages=()

    for cmd in fish tmux nvim fzf zoxide; do
        have "$cmd" && continue
        case "$cmd" in
            nvim) pkg="neovim" ;;
            *) pkg="$cmd" ;;
        esac
        apt_update
        apt_has "$pkg" || die "Package '$pkg' is not available in the configured apt sources."
        packages+=("$pkg")
    done

    for cmd in ghq eza lazygit ghostty; do
        have "$cmd" && continue
        apt_update
        apt_has "$cmd" && packages+=("$cmd")
    done

    if ((${#packages[@]} > 0)); then
        step "Installing tools from apt: ${packages[*]}"
        apt_install "${packages[@]}"
        ok "APT tools installed."
    fi

    # Fallbacks for packages missing from Debian/Ubuntu repositories.
    if ! have ghq; then
        install_archive_binary \
            "https://github.com/x-motemen/ghq/releases/latest/download/ghq_linux_${GHQ_ARCH}.zip" \
            ghq zip
    fi

    if ! have eza; then
        install_archive_binary \
            "https://github.com/eza-community/eza/releases/latest/download/eza_${EZA_ARCH}-unknown-linux-gnu.tar.gz" \
            eza tar
    fi

    if ! have lazygit; then
        local tag
        tag="$(curl -fsSIL -o /dev/null -w '%{url_effective}' \
            https://github.com/jesseduffield/lazygit/releases/latest |
            sed 's|.*/tag/v||')"
        [[ -n "$tag" ]] || die "Could not determine the latest LazyGit version."
        install_archive_binary \
            "https://github.com/jesseduffield/lazygit/releases/download/v${tag}/lazygit_${tag}_Linux_${LAZYGIT_ARCH}.tar.gz" \
            lazygit tar
    fi

    if ! have ghostty; then
        if have snap; then
            step "Installing Ghostty with snap"
            if run_privileged snap install ghostty --classic; then
                ok "Ghostty installed."
            else
                warn "Ghostty snap install failed. Get it from https://ghostty.org/download"
            fi
        else
            warn "Ghostty is not available in apt or snap. Get it from https://ghostty.org/download"
        fi
    fi
}

install_chezmoi() {
    add_local_bin
    if have chezmoi; then
        ok "chezmoi is already installed."
        return 0
    fi

    local installer
    step "Installing chezmoi into $LOCAL_BIN"
    installer="$(mktemp)"
    download "https://get.chezmoi.io" "$installer"
    sh "$installer" -b "$LOCAL_BIN" || {
        rm -f "$installer"
        die "chezmoi installation failed."
    }
    rm -f "$installer"
    hash -r
    have chezmoi || die "chezmoi installation failed."
    ok "chezmoi installed."
}

ensure_bash_path() {
    local rc="$HOME/.bashrc"
    [[ -f "$rc" ]] && grep -q 'dotfiles installer' "$rc" && return 0
    [[ -e "$rc" && ! -w "$rc" ]] && {
        warn "Add $LOCAL_BIN to PATH manually (cannot write $rc)."
        return 0
    }

    cat >>"$rc" <<'EOF'

# Added by dotfiles installer
case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) export PATH="$HOME/.local/bin:$PATH" ;;
esac
EOF
    ok "Added $LOCAL_BIN to ~/.bashrc."
}

init_chezmoi() {
    step "Loading dotfiles with chezmoi"
    chezmoi init "$REPO_URL" || die "chezmoi init failed."
}

show_plan() {
    local rel existing=0
    step "Files to manage in $HOME"
    while IFS= read -r rel; do
        [[ -n "$rel" ]] || continue
        printf '  %s\n' "$rel"
        [[ -e "$HOME/$rel" || -L "$HOME/$rel" ]] && existing=$((existing + 1))
    done < <(chezmoi managed --include files)

    if (( existing > 0 )); then
        warn "$existing existing file(s) will be backed up and replaced."
    fi
}

confirm() {
    (( ASSUME_YES )) && return 0
    [[ -t 0 ]] || return 1
    local reply
    read -r -p "$1 [y/N] " reply
    [[ "$reply" =~ ^[Yy]$ ]]
}

backup_files() {
    local stamp rel target count=0
    stamp="$(date +%Y%m%d-%H%M%S)"
    LAST_BACKUP="$BACKUP_ROOT/$stamp"

    while IFS= read -r rel; do
        [[ -n "$rel" ]] || continue
        target="$HOME/$rel"
        [[ -e "$target" || -L "$target" ]] || continue
        mkdir -p "$(dirname -- "$LAST_BACKUP/$rel")"
        cp -a -- "$target" "$LAST_BACKUP/$rel"
        count=$((count + 1))
    done < <(chezmoi status --include files | awk 'NF >= 2 { print $2 }')

    if (( count == 0 )); then
        LAST_BACKUP=""
        ok "No existing files need a backup."
    else
        ok "Backed up $count file(s) to $LAST_BACKUP"
    fi
}

setup_fish() {
    if fish -c 'type -q fisher' >/dev/null 2>&1; then
        ok "Fisher is already installed."
    else
        step "Installing Fisher with fish"
        fish -c 'curl -fsSL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source; and fisher install jorgebucaran/fisher' ||
            die "Fisher installation failed."
        ok "Fisher installed."
    fi

    step "Installing Fish plugins (Tide)"
    fish -c 'fisher update' || die "fisher update failed."
    ok "Fish plugins installed."
}

configure_tide() {
    fish -c 'type -q tide' >/dev/null 2>&1 || return 0
    (( ASSUME_YES )) && return 0
    [[ -t 0 ]] || return 0
    if confirm "Configure the Tide prompt now?"; then
        fish -c 'tide configure' || warn "Tide configuration skipped."
    fi
}

font_installed() {
    have fc-list || return 1
    local families
    families="$(fc-list : family 2>/dev/null)" || return 1
    grep -Fqi "$FONT_FAMILY" <<<"$families"
}

install_font() {
    if font_installed; then
        ok "$FONT_FAMILY is already installed."
        return 0
    fi

    local tmp archive dest
    tmp="$(mktemp -d)"
    archive="$tmp/font.zip"
    dest="${XDG_DATA_HOME:-$HOME/.local/share}/fonts/BlexMono"

    step "Installing $FONT_FAMILY"
    download "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/IBMPlexMono.zip" "$archive"
    mkdir -p "$dest"
    unzip -qo "$archive" -d "$dest" || die "Could not extract the font archive."
    fc-cache -f "$dest" >/dev/null 2>&1 || true
    rm -rf "$tmp"

    font_installed || die "The font was installed to $dest but fc-list cannot detect it."
    ok "$FONT_FAMILY installed."
}

verify_tools() {
    local cmd
    step "Verification"
    local version
    for cmd in fish tmux nvim lazygit zoxide eza ghq fzf chezmoi; do
        have "$cmd" || die "$cmd is required but was not found."
        case "$cmd" in
            tmux)
                version="$(tmux -V)" || die "tmux is not working."
                ;;
            ghq)
                ghq --help >/dev/null 2>&1 || die "ghq is not working."
                version="$(ghq --version 2>/dev/null || echo installed)"
                ;;
            *)
                version="$("$cmd" --version 2>/dev/null)" || die "$cmd is not working."
                version="${version%%$'\n'*}"
                ;;
        esac
        say "  $cmd: $version"
    done

    if have ghostty; then
        ok "Ghostty is installed."
    else
        warn "Ghostty is not installed; get it from https://ghostty.org/download"
    fi

    if font_installed; then
        ok "$FONT_FAMILY is detected."
    else
        warn "$FONT_FAMILY is not detected."
    fi

    if fish -c 'type -q fisher; and type -q tide' >/dev/null 2>&1; then
        ok "Fisher and Tide are available."
    else
        warn "Fisher or Tide is missing."
    fi
}

run_dry_run() {
    local cmd
    detect_os
    step "Dry run - nothing will be changed"
    say "System: $OS_NAME"

    for cmd in curl git unzip fc-cache fc-list fish tmux nvim fzf zoxide ghq eza lazygit chezmoi; do
        have "$cmd" && continue
        say "  would install: $cmd"
    done
    have ghostty || say "  would install: ghostty (only if available in apt)"
    font_installed || say "  would install: $FONT_FAMILY"

    say ""
    say "Would apply these files to $HOME after confirmation:"
    while IFS= read -r -d '' file; do
        printf '  .config/%s\n' "${file#"$SCRIPT_DIR"/dot_config/}"
    done < <(find "$SCRIPT_DIR/dot_config" -type f -print0 | sort -z)

    say ""
    say "Dry run complete."
}

run_install() {
    detect_os
    detect_arch
    add_local_bin

    if [[ ! -t 0 ]] && (( ! ASSUME_YES )); then
        die "No interactive terminal. Re-run with --yes."
    fi

    install_base_packages
    install_cli_tools
    install_chezmoi

    init_chezmoi
    show_plan

    step "Ready to apply"
    say "Existing files are backed up to $BACKUP_ROOT/<timestamp>."
    say "$LOCAL_BIN is added to ~/.bashrc if missing."
    confirm "Apply these changes?" || die "Cancelled. Nothing was changed."

    ensure_bash_path
    backup_files

    step "Applying dotfiles"
    chezmoi apply --force || die "chezmoi apply failed."
    ok "Dotfiles applied."

    setup_fish
    configure_tide
    install_font
    verify_tools

    step "Done"
    [[ -n "$LAST_BACKUP" ]] && say "Backups: $LAST_BACKUP"
    say "Your login shell was not changed. Start Fish with: fish"
    say "Make Fish your default later with: chsh -s \"$(command -v fish)\""
    say "Open a new terminal to load the new PATH."
}

while (($# > 0)); do
    case "$1" in
        --dry-run) DRY_RUN=1 ;;
        -y | --yes) ASSUME_YES=1 ;;
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

if (( DRY_RUN )); then
    run_dry_run
else
    run_install
fi
