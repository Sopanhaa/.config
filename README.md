## Terminal setup

| Tool | Description |
|---|---|
| [Ghostty](https://ghostty.org/) | Fast, modern terminal emulator |
| [tmux](https://github.com/tmux/tmux) | Terminal multiplexer for managing sessions and split panes |
| [Neovim](https://neovim.io/) | Modern, customizable terminal-based code editor |
| [LazyGit](https://github.com/jesseduffield/lazygit) | Terminal UI for Git |

### Fonts

- [BlexMono Nerd Font](https://www.nerdfonts.com/) Programming font with icons and symbols.

## Shell setup (Linux)

| Tool | Description |
|---|---|
| [Fish shell](https://fishshell.com/) | User-friendly command-line shell |
| [Fisher](https://github.com/jorgebucaran/fisher) | Fish plugin manager |
| [Tide](https://github.com/IlanCosman/tide) | Fish shell prompt theme |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | Smart directory navigation |
| [Eza](https://github.com/eza-community/eza) | Modern ls replacement |
| [ghq](https://github.com/x-motemen/ghq) | Local Git repository manager |
| [fzf](https://github.com/junegunn/fzf) | Interactive fuzzy finder |

## Installation

```bash
git clone https://github.com/Sopanhaa/.config.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

The installer:

1. Detects Debian, Ubuntu, or Kubuntu and checks `apt-get`.
2. Installs missing tools in order: base packages, CLI tools, chezmoi.
3. Shows the files it will manage and asks before changing anything.
4. Backs up existing files to `~/.dotfiles-backup/<timestamp>/`.
5. Applies the configs, installs Fisher and Tide, then the BlexMono font.
6. Verifies the installation and prints the installed versions.

Options:

```bash
./install.sh --dry-run   # show what would be installed
./install.sh --yes       # skip the confirmation prompt
./install.sh --help
```

Your login shell is **never** changed. Start Fish with `fish`; make it the default later with:

```bash
chsh -s "$(command -v fish)"
```

Ghostty is installed from apt or snap when available. Otherwise install it from [ghostty.org/download](https://ghostty.org/download).

## Usage

| Command | Purpose |
|---|---|
| `chezmoi diff` | Preview config changes |
| `chezmoi apply` | Apply config changes |
| `chezmoi edit <file>` | Edit a managed file |
| `chezmoi cd` | Enter the chezmoi source directory |

Backups are stored in `~/.dotfiles-backup/`. The installer is safe to run again: installed tools are skipped and only changed files are backed up.

## Structure

```text
.
├── dot_config/           # → ~/.config
│   ├── fish/             # Shell, plugins, ghq + fzf helper
│   ├── ghostty/          # Terminal and font
│   ├── lazygit/          # Git TUI theme
│   ├── nvim/             # Minimal plugin-free config
│   └── tmux/             # Prefix, splits, status bar
├── install.sh
└── README.md
```

## References

- [craftzdog/dotfiles](https://github.com/craftzdog/dotfiles) — Reference for tool choices and repository structure.

