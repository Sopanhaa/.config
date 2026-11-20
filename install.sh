#!/usr/bin/env bash
#
# Dotfiles installer for Debian, Ubuntu, and Kubuntu.
#
#   ./install.sh --check     report dependencies and configuration status
#   ./install.sh --dry-run   show the full plan, change nothing
#   ./install.sh --install   install dependencies and apply the dotfiles
#
# Options:
#   -y, --yes   skip the final confirmation prompt (non-interactive use)
#   -h, --help  show this help
set -euo pipefail

REPO_URL="${DOTFILES_REPO:-https://github.com/Sopanhaa/.config.git}"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_BIN="$HOME/.local/bin"
FONT_SCRIPT="$SCRIPT_DIR/scripts/install-font.sh"
FONT_FAMILY="BlexMono Nerd Font"
BACKUP_ROOT="$HOME/.dotfiles-backup"

MODE=""
ASSUME_YES=0
LAST_BACKUP=""
OS_NAME="unknown"
OS_ID=""
OS_LIKE=""
MISSING_PKGS=()

if [[ -t 1 ]]; then
    C_RESET=$'\033[0m'
    C_BOLD=$'\033[1m'
    C_BLUE=$'\033[34m'
    C_GREEN=$'\033[32m'
    C_YELLOW=$'\033[33m'
    C_RED=$'\033[31m'
else
    C_RESET=""
    C_BOLD=""
    C_BLUE=""
    C_GREEN=""
    C_YELLOW=""
    C_RED=""
fi

say() { printf '%s\n' "$*"; }
step() { printf '\n%s==>%s %s%s%s\n' "$C_BLUE" "$C_RESET" "$C_BOLD" "$*" "$C_RESET"; }
ok() { printf '%s  ok%s  %s\n' "$C_GREEN" "$C_RESET" "$*"; }
warn() { printf '%s  !%s   %s\n' "$C_YELLOW" "$C_RESET" "$*"; }
die() {
    printf '%s  x%s   %s\n' "$C_RED" "$C_RESET" "$*" >&2
    exit 1
}

trap 'rc=$?; if (( rc != 0 )); then printf "\nerror: command failed (exit %d): %s\n" "$rc" "$BASH_COMMAND" >&2; fi' ERR

usage() {
    cat <<'EOF'
Dotfiles installer for Debian, Ubuntu, and Kubuntu.

Usage:
  ./install.sh --check     check dependencies (read-only)
  ./install.sh --dry-run   show what would be done (read-only)
  ./install.sh --install   install dependencies and apply dotfiles

Options:
  -y, --yes    skip the final confirmation prompt
  -h, --help   show this help

The installer never changes your login shell. Backups are written to
~/.dotfiles-backup/<timestamp>/ before existing files are replaced.
EOF
}

have() { command -v "$1" >/dev/null 2>&1; }

add_local_bin_to_path() {
    case ":$PATH:" in
        *":$LOCAL_BIN:"*) ;;
        *) export PATH="$LOCAL_BIN:$PATH" ;;
    esac
}

load_os() {
    if [[ -r /etc/os-release ]]; then
        # shellcheck disable=SC1091
        . /etc/os-release
        OS_NAME="${PRETTY_NAME:-${NAME:-Linux}}"
        OS_ID="${ID:-}"
        OS_LIKE="${ID_LIKE:-}"
    fi
}

is_debian_like() {
    case " ${OS_ID} ${OS_LIKE} " in
        *" debian "* | *" ubuntu "*) return 0 ;;
        *) return 1 ;;
    esac
}

require_debian_like() {
    load_os
    is_debian_like ||
        die "Unsupported system: $OS_NAME. This installer supports Debian, Ubuntu, and Kubuntu only."
    have apt-get || die "apt-get is required but was not found on this system."
}

package_for() {
    case "$1" in
        curl) echo curl ;;
        git) echo git ;;
        fish) echo fish ;;
        unzip) echo unzip ;;
        fc-cache | fc-list) echo fontconfig ;;
        *) echo "" ;;
    esac
}

collect_missing_packages() {
    MISSING_PKGS=()
    local cmd pkg
    for cmd in curl git fish unzip fc-cache fc-list; do
        have "$cmd" && continue
        pkg="$(package_for "$cmd")"
        [[ -n "$pkg" ]] || continue
        [[ " ${MISSING_PKGS[*]:-} " == *" $pkg "* ]] && continue
        MISSING_PKGS+=("$pkg")
    done

    # HTTPS downloads (chezmoi, Fisher, the font) need CA certificates.
    if [[ ! -e /etc/ssl/certs/ca-certificates.crt ]]; then
        MISSING_PKGS+=("ca-certificates")
    fi
}

run_privileged() {
    if (( EUID == 0 )); then
        "$@"
    elif have sudo; then
        sudo "$@"
    else
        die "Root access is required for: $* (sudo is not installed)."
    fi
}

install_packages() {
    (($# > 0)) || return 0
    step "Installing missing packages with apt-get: $*"
    run_privileged apt-get update -qq ||
        die "apt-get update failed. Check your network connection and apt sources."
    run_privileged env DEBIAN_FRONTEND=noninteractive apt-get install -y "$@" ||
        die "Package installation failed."
    ok "Packages installed."
}

chezmoi_version() {
    chezmoi --version 2>/dev/null | head -n1 | awk '{print $3}' | tr -d ','
}

install_chezmoi() {
    add_local_bin_to_path

    if have chezmoi; then
        ok "chezmoi $(chezmoi_version) is already installed."
        return 0
    fi

    have curl || die "curl is required to install chezmoi."
    step "Installing chezmoi into $LOCAL_BIN"
    mkdir -p "$LOCAL_BIN"

    local installer
    installer="$(mktemp)"
    if ! curl -fsSL https://get.chezmoi.io -o "$installer"; then
        rm -f "$installer"
        die "Could not download the chezmoi installer. Check your network connection."
    fi
    if ! sh "$installer" -b "$LOCAL_BIN"; then
        rm -f "$installer"
        die "The chezmoi installer failed."
    fi
    rm -f "$installer"
    hash -r

    have chezmoi ||
        die "chezmoi was installed but is not on PATH. Add $LOCAL_BIN to PATH and re-run."
    ok "Installed chezmoi $(chezmoi_version)."
}

ensure_bash_path() {
    local rc="$HOME/.bashrc"

    if [[ -f "$rc" ]] && grep -q 'dotfiles installer: user-local binaries' "$rc"; then
        ok "$HOME/.bashrc already adds $HOME/.local/bin to PATH."
        return 0
    fi
    if [[ -f "$rc" ]] && grep -q '\.local/bin' "$rc"; then
        ok "$HOME/.bashrc already references $HOME/.local/bin."
        return 0
    fi
    if [[ -e "$rc" && ! -w "$rc" ]]; then
        warn "Cannot write $rc. Add $LOCAL_BIN to PATH manually."
        return 0
    fi

    cat >>"$rc" <<'EOF'

# Added by dotfiles installer: user-local binaries
case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) export PATH="$HOME/.local/bin:$PATH" ;;
esac
EOF
    ok "Added $HOME/.local/bin to $HOME/.bashrc (open a new terminal to use it)."
}

init_chezmoi() {
    step "Initializing chezmoi from $REPO_URL"
    chezmoi init "$REPO_URL" ||
        die "chezmoi init failed. Check your network connection and repository URL."
    ok "chezmoi source: $(chezmoi source-path)"
}

managed_files() {
    chezmoi managed --include files
}

pending_files() {
    chezmoi status --include files | awk 'NF >= 2 { print $2 }'
}

show_plan() {
    step "Files that chezmoi will manage in $HOME"
    local rel existing=0
    while IFS= read -r rel; do
        [[ -n "$rel" ]] || continue
        printf '  %s\n' "$rel"
        if [[ -e "$HOME/$rel" || -L "$HOME/$rel" ]]; then
            existing=$((existing + 1))
        fi
    done < <(managed_files)

    if (( existing > 0 )); then
        say ""
        warn "$existing existing file(s) will be backed up before being replaced."
    fi
}

confirm() {
    (( ASSUME_YES )) && return 0
    [[ -t 0 ]] || return 1
    local reply
    read -r -p "$1 [y/N] " reply
    [[ "$reply" =~ ^[Yy]$ ]]
}

backup_pending_files() {
    local stamp rel target dest count=0
    stamp="$(date +%Y%m%d-%H%M%S)"
    LAST_BACKUP="$BACKUP_ROOT/$stamp"

    while IFS= read -r rel; do
        [[ -n "$rel" ]] || continue
        target="$HOME/$rel"
        [[ -e "$target" || -L "$target" ]] || continue

        dest="$LAST_BACKUP/$rel"
        mkdir -p "$(dirname -- "$dest")"
        cp -a -- "$target" "$dest"
        count=$((count + 1))
    done < <(pending_files)

    if (( count == 0 )); then
        LAST_BACKUP=""
        ok "No existing files need a backup."
    else
        ok "Backed up $count file(s) to $LAST_BACKUP"
    fi
}

setup_fish() {
    have fish || die "fish is required but is not installed."

    if fish -c 'type -q fisher' >/dev/null 2>&1; then
        ok "Fisher is already installed."
    else
        step "Installing Fisher with fish"
        fish -c 'curl -fsSL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source; and fisher install jorgebucaran/fisher' ||
            die "Fisher installation failed."
        ok "Fisher installed."
    fi

    step "Installing Fish plugins from fish_plugins (Tide)"
    fish -c 'fisher update' || die "fisher update failed."
    ok "Fish plugins are up to date."
}

configure_tide() {
    if ! fish -c 'type -q tide' >/dev/null 2>&1; then
        warn "Tide was not installed; skipping prompt configuration."
        return 0
    fi
    if [[ ! -t 0 ]]; then
        say "Skipping 'tide configure' (no interactive terminal)."
        say "Run it later with: fish -c 'tide configure'"
        return 0
    fi

    if confirm "Tide is installed. Configure the prompt now?"; then
        fish -c 'tide configure' || warn "tide configure did not finish. Run it later with: fish -c 'tide configure'"
    else
        say "Skipped. Run later with: fish -c 'tide configure'"
    fi
}

font_installed() {
    have fc-list || return 1
    local families
    families="$(fc-list : family 2>/dev/null)" || return 1
    grep -Fqi "BlexMono Nerd Font" <<<"$families"
}

install_font() {
    [[ -x "$FONT_SCRIPT" ]] || die "Font installer not found or not executable: $FONT_SCRIPT"
    step "Installing $FONT_FAMILY"
    "$FONT_SCRIPT" || die "Font installation failed."
}

final_summary() {
    step "Installation complete"
    say "Dotfiles are managed by chezmoi."
    if [[ -n "$LAST_BACKUP" ]]; then
        say "Backups: $LAST_BACKUP"
    fi
    say "Your login shell was NOT changed. Start Fish with: fish"
    say "To make Fish your default later: chsh -s \"$(command -v fish)\""
    say "Open a new terminal so PATH changes take effect."
    say "Useful commands: chezmoi diff, chezmoi apply, chezmoi edit <file>"
}

run_install() {
    if [[ ! -t 0 ]] && (( ! ASSUME_YES )); then
        die "No interactive terminal. Re-run with --yes or from a terminal."
    fi

    require_debian_like
    add_local_bin_to_path

    # First-run chezmoi init prompts for name/email, which needs a TTY.
    if [[ ! -t 0 ]]; then
        local chezmoi_config="${XDG_CONFIG_HOME:-$HOME/.config}/chezmoi/chezmoi.toml"
        if [[ ! -f "$chezmoi_config" ]]; then
            die "First-time setup needs an interactive terminal for chezmoi's name/email prompt. Run without --yes."
        fi
    fi

    collect_missing_packages
    if ((${#MISSING_PKGS[@]} > 0)); then
        install_packages "${MISSING_PKGS[@]}"
    else
        ok "All required system packages are already installed."
    fi
    hash -r

    install_chezmoi
    init_chezmoi
    show_plan

    step "Ready to apply"
    say "chezmoi will write the files listed above into $HOME."
    say "Existing versions are backed up to $BACKUP_ROOT/<timestamp>."
    say "$HOME/.local/bin is added to $HOME/.bashrc if it is missing."
    confirm "Apply these changes?" || die "Installation cancelled. Nothing was changed."

    ensure_bash_path
    backup_pending_files

    step "Applying dotfiles with chezmoi"
    chezmoi apply --force || die "chezmoi apply failed. Backups are in ${LAST_BACKUP:-$BACKUP_ROOT}."
    ok "Dotfiles applied."

    setup_fish
    configure_tide
    install_font
    final_summary
}

run_check() {
    load_os
    local failed=0

    step "System"
    say "OS: $OS_NAME"
    if is_debian_like; then
        ok "Debian-based system"
    else
        warn "Not a Debian-based system; apt steps will not work."
        failed=1
    fi
    if have apt-get; then
        ok "apt-get is available"
    else
        warn "apt-get is missing"
        failed=1
    fi

    step "Required commands"
    local cmd
    for cmd in curl git fish unzip fc-cache fc-list; do
        if have "$cmd"; then
            ok "$cmd -> $(command -v "$cmd")"
        else
            warn "$cmd is missing (package: $(package_for "$cmd"))"
            failed=1
        fi
    done
    if [[ -e /etc/ssl/certs/ca-certificates.crt ]]; then
        ok "CA certificates are present"
    else
        warn "ca-certificates is missing (package: ca-certificates)"
        failed=1
    fi

    step "chezmoi"
    if have chezmoi; then
        ok "$(chezmoi --version 2>/dev/null | head -n1)"
    else
        warn "chezmoi is missing; --install will put it in $LOCAL_BIN"
        failed=1
    fi

    step "Fish add-ons"
    if have fish; then
        if fish -c 'type -q fisher' >/dev/null 2>&1; then
            ok "Fisher is installed"
        else
            warn "Fisher is missing; --install will add it"
        fi
        if fish -c 'type -q tide' >/dev/null 2>&1; then
            ok "Tide is installed"
        else
            warn "Tide is missing; --install will add it"
        fi
    else
        warn "fish is missing; cannot check Fisher or Tide"
    fi

    step "Font"
    if font_installed; then
        ok "$FONT_FAMILY is detected"
    else
        warn "$FONT_FAMILY is not detected; --install will add it"
    fi

    step "Configuration"
    if have chezmoi; then
        local src
        src="$(chezmoi source-path 2>/dev/null || true)"
        if [[ -n "$src" && -d "$src" ]]; then
            ok "chezmoi source: $src"
            local pending
            pending="$(chezmoi status 2>/dev/null | wc -l | tr -d ' ')"
            say "  Pending changes: $pending"
        else
            warn "chezmoi source is not initialized yet"
        fi
    else
        warn "chezmoi is not available yet"
    fi

    say ""
    if (( failed )); then
        warn "Some required dependencies are missing. Run: ./install.sh --install"
        exit 1
    fi
    ok "All required dependencies are present."
}

list_targets() {
    local file rel
    while IFS= read -r -d '' file; do
        rel="${file#"$SCRIPT_DIR"/dot_config/}"
        printf '.config/%s\n' "$rel"
    done < <(find "$SCRIPT_DIR/dot_config" -type f -print0 | sort -z)
}

run_dry_run() {
    load_os
    step "Dry run - nothing will be changed"
    say "OS: $OS_NAME"
    if ! is_debian_like; then
        warn "Not a Debian-based system; the apt steps would not work."
    fi

    collect_missing_packages
    if ((${#MISSING_PKGS[@]} > 0)); then
        say "Would install system packages with apt-get: ${MISSING_PKGS[*]}"
    else
        ok "All required system packages are already installed."
    fi

    if have chezmoi; then
        ok "chezmoi is already installed."
    else
        say "Would install chezmoi into $LOCAL_BIN."
    fi

    say "Would run: chezmoi init $REPO_URL"
    say "Would back up any existing target files to $BACKUP_ROOT/<timestamp>."
    say "Would apply these files to $HOME:"
    list_targets | sed 's/^/  /'
    say "Would install Fisher and Fish plugins (Tide) using fish."
    say "Would offer to run: fish -c 'tide configure'"
    if font_installed; then
        ok "$FONT_FAMILY is already available."
    else
        say "Would install $FONT_FAMILY."
    fi

    say ""
    say "Dry run complete. No changes were made."
}

while (($# > 0)); do
    case "$1" in
        --check) MODE="check" ;;
        --dry-run) MODE="dry-run" ;;
        --install) MODE="install" ;;
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

if [[ -z "$MODE" ]]; then
    usage
    exit 1
fi

if (( EUID == 0 )) && [[ -n "${SUDO_USER:-}" ]]; then
    die "Do not run this script with sudo. Run it as your normal user; it asks for sudo only when needed."
fi

case "$MODE" in
    check) run_check ;;
    dry-run) run_dry_run ;;
    install) run_install ;;
esac
