set -g fish_user_paths "$HOME/.cargo/bin" $fish_user_paths
set -g fish_user_paths "/usr/local/sbin" $fish_user_paths
set -g fish_user_paths "/usr/local/opt/node@10/bin" $fish_user_paths

set -g JAVA_HOME /usr/local/Cellar/openjdk/15.0.2

status --is-interactive; and source (rbenv init -|psub)

source /usr/local/opt/asdf/asdf.fish
