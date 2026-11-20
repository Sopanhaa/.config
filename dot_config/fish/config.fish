# =====================================
# Fish shell configuration
# Plugins are managed with Fisher (see fish_plugins)
# =====================================

if status is-interactive
    # Disable the welcome message
    set -g fish_greeting
end

# --- Environment ---------------------------------------------------------
set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx PAGER less
set -gx LESS '-R'

fish_add_path $HOME/.local/bin

# --- Integrations --------------------------------------------------------
if type -q zoxide
    zoxide init fish | source
end

if type -q fzf
    # Requires fzf >= 0.48; older versions are skipped quietly
    fzf --fish 2>/dev/null | source
end

# --- Abbreviations -------------------------------------------------------
if status is-interactive
    abbr --add v nvim
    abbr --add lg lazygit

    abbr --add gs 'git status --short --branch'
    abbr --add gd 'git diff'
    abbr --add gl 'git log --oneline --graph --decorate -20'

    if type -q eza
        abbr --add ls 'eza --icons --group-directories-first'
        abbr --add ll 'eza --long --icons --group-directories-first --git'
        abbr --add la 'eza --long --all --icons --group-directories-first --git'
        abbr --add lt 'eza --tree --level=2 --icons --group-directories-first'
    end
end
