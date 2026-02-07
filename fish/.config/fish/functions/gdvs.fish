function gdvs --wraps='git diff --staged' --description 'alias gdvs=git diff --staged'
    git diff --staged $argv
end
