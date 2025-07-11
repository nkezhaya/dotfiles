set -g fish_user_paths "$HOME/.cargo/bin" $fish_user_paths
set -g fish_user_paths "$HOME/go/bin" $fish_user_paths
set -g fish_user_paths "/usr/local/sbin" $fish_user_paths
set -g fish_user_paths "/usr/local/opt/node@10/bin" $fish_user_paths
set -g fish_user_paths "/opt/homebrew/bin" $fish_user_paths

set -g GO_PATH "$HOME/go"
set -g JAVA_HOME /usr/local/Cellar/openjdk/15.0.2
set -Ux EDITOR /opt/homebrew/bin/nvim

# neovim is great for man pages
set -gx MANPAGER "nvim +Man!"

# Signing git commits
set -gx GPG_TTY (tty)

# Ruby, rbenv
status --is-interactive; and source (rbenv init -|psub)

# pyenv
pyenv init - fish | source

# Spicetify
fish_add_path /Users/nkezhaya/.spicetify

# asdf
if test -z $ASDF_DATA_DIR
    set _asdf_shims "$HOME/.asdf/shims"
else
    set _asdf_shims "$ASDF_DATA_DIR/shims"
end
set -gx --prepend PATH $_asdf_shims
set --erase _asdf_shims
