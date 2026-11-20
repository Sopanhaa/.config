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

```bash
git clone https://github.com/Sopanhaa/.config.git ~/dotfiles
cd ~/dotfiles

./install.sh              # symlink config/* into ~/.config (backs up existing files)
./scripts/install-font.sh # install BlexMono Nerd Font
```

Then, in a new terminal:

```bash
# Install Fisher, then the plugins listed in config/fish/fish_plugins
curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source
fisher install jorgebucaran/fisher
fisher update

# Pick a Tide style once
tide configure
```

The first Neovim start bootstraps [lazy.nvim](https://github.com/folke/lazy.nvim) and installs all plugins automatically.

### Packages

Install the tools you need, for example:

```bash
sudo apt install fish tmux neovim fzf zoxide eza ghq git
```

LazyGit and Ghostty should be installed from their official instructions (or your distribution's package manager if available).

### What `install.sh` does

- Symlinks every folder in `config/` to `~/.config/<name>`.
- Moves any conflicting existing config to `<name>.bak.<timestamp>` instead of deleting it.
- Is safe to re-run; already-correct links are left untouched.

## Structure

```text
.
├── config/
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
├── install.sh
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
