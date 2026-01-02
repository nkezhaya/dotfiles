function __bobthefish_prompt_node -S -d 'Display current node version'
    set -l should_show

    if [ "$theme_display_node" = 'always' -o "$theme_display_nvm" = 'yes' ]
        set should_show 1
    else if [ "$theme_display_node" = 'yes' ]
        __bobthefish_prompt_find_file_up "$PWD" package.json .nvmrc .node-version
        and set should_show 1
    end

    [ -z "$should_show" ]
    and return

    set -l node_manager
    set -l node_manager_dir

    if type -q nvm
      set node_manager 'nvm'
      set node_manager_dir $NVM_DIR
    else if type -fq fnm
      set node_manager 'fnm'
      set node_manager_dir $FNM_DIR
    end

    [ -n "$node_manager_dir" ]
    or return

    set -l node_version ("$node_manager" current 2> /dev/null)

    [ -z $node_version -o "$node_version" = 'none' -o "$node_version" = 'system' ]
    and return

    [ -n "$color_nvm" ]
    and set -x color_node $color_nvm

    __bobthefish_start_segment $color_node
    echo -ns $node_glyph $node_version ' '
    set_color normal
end
