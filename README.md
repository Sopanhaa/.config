## Terminal Setup

| Tool | Description |
|---|---|
| [Ghostty](https://github.com/ghostty-org/ghostty) | Fast, modern terminal emulator |
| [tmux](https://github.com/tmux/tmux) | Terminal multiplexer for managing sessions and panes |
| [Neovim](https://github.com/neovim/neovim) | Modern terminal-based code editor |
| [LazyGit](https://github.com/jesseduffield/lazygit) | Terminal UI for Git |

## Fonts

- [BlexMono Nerd Font](https://github.com/ryanoasis/nerd-fonts) — Programming font with icons and symbols.

## Fish Shell Setup

| Tool | Description |
|---|---|
| [Fish](https://github.com/fish-shell/fish-shell) | User-friendly interactive shell |
| [Fisher](https://github.com/jorgebucaran/fisher) | Fish plugin manager |
| [Tide](https://github.com/IlanCosman/tide) | Minimal Fish prompt theme |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | Smart directory navigation |
| [Eza](https://github.com/eza-community/eza) | Modern `ls` replacement |
| [ghq](https://github.com/x-motemen/ghq) | Local Git repository manager |
| [fzf](https://github.com/junegunn/fzf) | Interactive fuzzy finder |

## Installation

Supports **Debian, Ubuntu, and Kubuntu** with Bash. The installer checks for missing tools before using them, installs only what is needed, and manages the configs with [chezmoi](https://www.chezmoi.io/).

```bash
git clone https://github.com/Sopanhaa/.config.git ~/dotfiles
cd ~/dotfiles
./install.sh --check
./install.sh --dry-run
./install.sh --install
```

`--install` lists the files it will manage and asks for confirmation before writing anything.

### What the installer does

1. Verifies that the system is Debian-based and that `apt-get` exists.
2. Installs only the missing system packages: `curl`, `git`, `fish`, `unzip`, `fontconfig`, and `ca-certificates`.
3. Installs **chezmoi** into `~/.local/bin` (it never assumes chezmoi exists).
4. Adds `~/.local/bin` to `~/.bashrc` if PATH does not already include it.
5. Runs `chezmoi init`, lists the managed files, and asks for confirmation.
6. Backs up existing files to `~/.dotfiles-backup/<timestamp>/` before replacing them.
7. Applies the configs with `chezmoi apply`.
8. Installs Fisher and the plugins from `fish_plugins` (Tide) **using Fish**.
9. Offers to run `tide configure` only when Tide is installed and a terminal is attached.
10. Installs the BlexMono Nerd Font and verifies it with `fc-list`.

The script never changes your login shell. Start Fish with `fish`; make it the default later with:

```bash
chsh -s "$(command -v fish)"
```

### Installer modes

| Command | Description |
|---|---|
| `./install.sh --check` | Read-only report of the OS, dependencies, chezmoi, Fisher/Tide, font, and pending changes. Exits `1` if a required dependency is missing. |
| `./install.sh --dry-run` | Prints every action the installer would take. Changes nothing. |
| `./install.sh --install` | Installs dependencies and applies the dotfiles. |
| `./install.sh --install --yes` | Skips the final confirmation. Use only after the first interactive install. |

### Dependencies

| Tool | Needed for | Installed automatically |
|---|---|---|
| Bash | Running the installer | – |
| `curl` | Downloading chezmoi, Fisher, and the font | yes (`apt`) |
| `git` | chezmoi source management | yes (`apt`) |
| `fish` | Shell config, Fisher, Tide | yes (`apt`) |
| `unzip` | Extracting the font archive | yes (`apt`) |
| `fontconfig` | `fc-cache` / `fc-list` font detection | yes (`apt`) |
| `ca-certificates` | HTTPS downloads | yes (`apt`) |
| [chezmoi](https://www.chezmoi.io/) | Applying the configs | yes (user binary in `~/.local/bin`) |
| Fisher + Tide | Fish plugins | yes (via Fish) |

Optional tools are **not** installed: Neovim, tmux, LazyGit, Ghostty, fzf, zoxide, eza, and ghq. Install them separately from the links above.

### Re-running the installer

The installer is safe to run repeatedly:

- Installed packages, chezmoi, Fisher, Tide, and the font are detected and skipped.
- Only files that are about to change are backed up.
- `~/.bashrc` is edited at most once.

The first Neovim start bootstraps [lazy.nvim](https://github.com/folke/lazy.nvim) and installs all plugins automatically.

### Manual chezmoi workflow

| Command | Purpose |
|---|---|
| `chezmoi edit ~/.config/fish/config.fish` | Edit a managed file |
| `chezmoi diff` | Preview pending changes |
| `chezmoi apply` | Write changes to `$HOME` |
| `chezmoi add ~/.config/foo` | Start managing an existing file |
| `chezmoi cd` | Open the source repository |
| `chezmoi update` | Pull the latest changes and apply |

### How it works

- Chezmoi copies files from this repo into `$HOME`; no symlinks are used.
- `dot_config/` maps to `~/.config/`, so `dot_config/tmux/tmux.conf` becomes `~/.config/tmux/tmux.conf`.
- `.chezmoi.toml.tmpl` prompts for name, email, and GitHub username on first init.
- `README.md`, `install.sh`, and `scripts/` are excluded via `.chezmoiignore`.

## Structure

```text
.
├── .chezmoi.toml.tmpl        # Prompts for name/email on first init
├── .chezmoiignore            # Repo files that are not applied
├── dot_config/               # → ~/.config
│   ├── ghostty/config        # Font, theme, window padding
│   ├── fish/
│   │   ├── config.fish       # Env, integrations, abbreviations
│   │   ├── fish_plugins      # Fisher plugin list (Tide)
│   │   └── functions/        # gcf, mkcd
│   ├── lazygit/config.yml    # Catppuccin Mocha theme
│   ├── nvim/
│   │   ├── init.lua
│   │   └── lua/
│   │       ├── config/       # options, keymaps, lazy.nvim bootstrap
│   │       └── plugins/      # colorscheme, editor, ui, git specs
│   └── tmux/tmux.conf        # Prefix, splits, status bar, popups
├── scripts/install-font.sh    # Font install with detection and verification
├── install.sh                # Dependency checks, chezmoi bootstrap, backups
└── README.md
```

## Troubleshooting

| Symptom | Fix |
|---|---|
| `curl: command not found` | Run `./install.sh --install`; it installs curl first. If apt also fails, install it manually with `sudo apt-get install curl`. |
| `chezmoi: command not found` | `~/.local/bin` is not on PATH in the current shell. Run `source ~/.bashrc` or open a new terminal. |
| `fisher: command not found` or `tide: command not found` | These are Fish functions, not Bash commands. Run `fish -c 'fisher update'`, or start `fish` first. |
| BlexMono font not detected | Run `fc-cache -f ~/.local/share/fonts`, then `fc-list \| grep -i BlexMono`. |
| Cannot confirm the prompt (CI or no TTY) | Run `./install.sh --install` in an interactive terminal. `--yes` cannot answer chezmoi's first-run name/email prompt. |
| Existing config was replaced | Restore it from `~/.dotfiles-backup/<timestamp>/`. |

## Key Bindings

### tmux

| Binding | Action |
|---|---|
| `Ctrl+Space` | Prefix |
| `Prefix + \|` / `Prefix + -` | Split horizontally / vertically |
| `Prefix + h/j/k/l` | Move between panes |
| `Prefix + g` | Open LazyGit in a popup |
| `Prefix + f` | Open a Fish popup |
| `Prefix + r` | Reload configuration |

### Neovim

Leader is `Space`.

| Binding | Action |
|---|---|
| `<leader>w` / `<leader>q` | Save / quit |
| `<leader>e` | Toggle file explorer |
| `<leader>ff` / `<leader>fg` | Find files / live grep |
| `<leader>fb` / `<leader>fr` | Buffers / recent files |
| `<leader>gg` | Open LazyGit |
| `Ctrl+h/j/k/l` | Move between windows |

## References

- [craftzdog/dotfiles](https://github.com/craftzdog/dotfiles) — reference for tool choices and repository structure.


