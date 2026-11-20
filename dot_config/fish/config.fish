# Fish shell configuration

if status is-interactive
    set -g fish_greeting
end

set -gx EDITOR nvim
set -gx VISUAL nvim

fish_add_path $HOME/.local/bin

if type -q zoxide
    zoxide init fish | source
end

if type -q fzf
    fzf --fish 2>/dev/null | source
end

if status is-interactive
    abbr --add lg lazygit
    abbr --add gs 'git status --short --branch'
    abbr --add gd 'git diff'

    if type -q eza
        abbr --add ls 'eza --icons --group-directories-first'
        abbr --add ll 'eza --long --icons --group-directories-first --git'
        abbr --add la 'eza --long --all --icons --group-directories-first --git'
    end
end
