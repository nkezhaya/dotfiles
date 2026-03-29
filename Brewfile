# dotfiles bootstrap
# Install with:
#   brew bundle --file=./Brewfile
#
# Scope: packages/apps that this repo appears to depend on directly.
# Keep personal extras out unless they are referenced by config here.

# Third-party taps
# yabai/skhd are distributed from koekeishiya's tap.
tap "koekeishiya/formulae"
# Nerd Font casks live here.
tap "homebrew/cask-fonts"

# Core CLI tools
brew "stow"
brew "fish"
brew "neovim"
brew "tmux"
brew "reattach-to-user-namespace"
brew "jq"
brew "timewarrior"
brew "mise"
brew "pyenv"
brew "rbenv"
brew "openjdk"
brew "node"
brew "python"

# Window manager + hotkeys
brew "yabai"
brew "skhd"

# GUI apps referenced by this repo
cask "alacritty"
cask "finicky"
cask "xbar"
cask "google-chrome"
cask "microsoft-edge"

# Fonts referenced by alacritty config
cask "font-jetbrains-mono-nerd-font"

# Notes:
# - tmux plugin manager (TPM) is installed separately:
#     git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
# - yb-new-term uses Python packages that Homebrew does not install here:
#     pip3 install iterm2 pyobjc
# - yabai scripting addition still requires the usual manual macOS setup/signing steps.
