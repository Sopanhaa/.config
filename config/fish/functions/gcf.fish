function gcf --description 'Jump to a ghq-managed repository with fzf'
    set -l repo (
        ghq list --full-path |
        fzf --height 40% --reverse --prompt='ghq> '
    )

    test -n "$repo"; and cd "$repo"
end
