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

Managed with [chezmoi](https://www.chezmoi.io/). Chezmoi treats this repository as its source and writes the real files into `$HOME` — no symlinks involved.

```bash
# One-liner: install chezmoi, clone this repo, and apply the configs
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply Sopanhaa
```

Or clone first and use the bootstrap script:

```bash
git clone https://github.com/Sopanhaa/.config.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

Before the first apply on a machine that already has configs, preview what will change with `chezmoi diff`.

Then, in a new terminal:

```bash
./scripts/install-font.sh # install BlexMono Nerd Font

# Install Fisher, then the plugins listed in dot_config/fish/fish_plugins
curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source
fisher install jorgebucaran/fisher
fisher update

# Pick a Tide style once
tide configure
```

The first Neovim start bootstraps [lazy.nvim](https://github.com/folke/lazy.nvim) and installs all plugins automatically.

### Daily use

| Command | Purpose |
|---|---|
| `chezmoi edit ~/.config/fish/config.fish` | Edit a managed file |
| `chezmoi diff` | Preview pending changes |
| `chezmoi apply` | Write changes to `$HOME` |
| `chezmoi add ~/.config/foo` | Start managing an existing file |
| `chezmoi cd` | Open the source repository |
| `chezmoi update` | Pull the latest changes and apply |

### Packages

Install the tools you need, for example:

```bash
sudo apt install fish tmux neovim fzf zoxide eza ghq git
```

LazyGit and Ghostty should be installed from their official instructions (or your distribution's package manager if available).

### How it works

- Chezmoi copies files from this repo into `$HOME` and keeps track of what it manages.
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
├── scripts/install-font.sh
├── install.sh                # chezmoi bootstrap
└── README.md
```

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

## License

Personal configuration files for learning and everyday development.
