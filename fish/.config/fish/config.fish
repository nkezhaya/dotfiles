set -g fish_user_paths "$HOME/.cargo/bin" $fish_user_paths
set -g fish_user_paths "/usr/local/sbin" $fish_user_paths
set -g fish_user_paths "/usr/local/opt/node@10/bin" $fish_user_paths
set -g fish_user_paths "/opt/homebrew/bin" $fish_user_paths

set -g JAVA_HOME /usr/local/Cellar/openjdk/15.0.2

# Signing git commits
set -gx GPG_TTY (tty)

# Ruby, rbenv
status --is-interactive; and source (rbenv init -|psub)

source /opt/homebrew/opt/asdf/asdf.fish

test -e {$HOME}/.iterm2_shell_integration.fish ; and source {$HOME}/.iterm2_shell_integration.fish
