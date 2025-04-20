set -g fish_user_paths "$HOME/.cargo/bin" $fish_user_paths
set -g fish_user_paths "$HOME/go/bin" $fish_user_paths
set -g fish_user_paths "/usr/local/sbin" $fish_user_paths
set -g fish_user_paths "/usr/local/opt/node@10/bin" $fish_user_paths
set -g fish_user_paths "/opt/homebrew/bin" $fish_user_paths

set -g GO_PATH "$HOME/go"
set -g JAVA_HOME /usr/local/Cellar/openjdk/15.0.2

# neovim is great for man pages
set -gx MANPAGER "nvim +Man!"

# Signing git commits
set -gx GPG_TTY (tty)

# Ruby, rbenv
status --is-interactive; and source (rbenv init -|psub)

# Spicetify
fish_add_path /Users/nkezhaya/.spicetify

# asdf
fish_add_path "$ASDF_DIR/bin"
fish_add_path "$HOME/.asdf/shims"

if status --is-interactive && type -q asdf
  source (brew --prefix asdf)/libexec/asdf.fish
end
