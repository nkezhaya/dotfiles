set -g fish_user_paths "$HOME/.cargo/bin" $fish_user_paths
set -g fish_user_paths "$HOME/go/bin" $fish_user_paths
set -g fish_user_paths "/usr/local/sbin" $fish_user_paths
set -g fish_user_paths "/usr/local/opt/node@10/bin" $fish_user_paths
set -g fish_user_paths "/opt/homebrew/bin" $fish_user_paths
set -g fish_user_paths "$HOME/.local/bin" $fish_user_paths

set -g GO_PATH "$HOME/go"
set -g JAVA_HOME /usr/local/Cellar/openjdk/15.0.2
set -gx EDITOR /opt/homebrew/bin/nvim

# neovim is great for man pages
set -gx MANPAGER "nvim +Man!"

# Signing git commits
set -gx GPG_TTY (tty)

# Faster compile times, set to half of the num CPU cores
set -gx MIX_OS_DEPS_COMPILE_PARTITION_COUNT (math (sysctl -n hw.ncpu) / 2)

# Ruby, rbenv
status --is-interactive; and source (rbenv init -|psub)

# pyenv
set -gx PYENV_ROOT "$HOME/.pyenv"
pyenv init - fish | source

# Spicetify
fish_add_path /Users/nkezhaya/.spicetify

# mise
mise activate fish | source

if test -e config.local.fish
  source config.local.fish
end
