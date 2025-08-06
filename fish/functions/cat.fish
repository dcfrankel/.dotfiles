function cat --wraps='bat --paging=never' --description 'alias cat bat --paging=never'
    if command -q bat
        bat --paging=never $argv
    else
        command cat $argv
    end
end
