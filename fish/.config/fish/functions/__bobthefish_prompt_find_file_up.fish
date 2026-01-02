function __bobthefish_prompt_find_file_up -S -d 'Find file(s), going up the parent directories'
    set -l dir "$argv[1]"
    set -l files $argv[2..-1]

    if test -z "$dir"
        or test -z "$files"
        return 1
    end

    while [ "$dir" ]
        for f in $files
            if [ -e "$dir/$f" ]
                return
            end
        end

        [ "$dir" = '/' ]
        and return 1

        set dir (__bobthefish_dirname "$dir")
    end
    return 1
end
