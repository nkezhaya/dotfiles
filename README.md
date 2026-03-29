## Setup

Clone `dotfiles` to your home directory (`~/dotfiles`), then install the Homebrew packages from the root `Brewfile`:

```bash
brew bundle --file=~/dotfiles/Brewfile
```

This installs the core tools and apps referenced by this repo, including `stow`.

## Stow

After installing dependencies, stow the configs you want from the repo root.

Example:

```bash
stow fish tmux vim yabai skhd alacritty
```

## tmux plugin manager

If you are stowing tmux, also install TPM:

```bash
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
```

## Notes

- `yabai/.bin/yb-new-term` also expects Python packages installed separately:

```bash
pip3 install iterm2 pyobjc
```
- `yabai` scripting addition still requires the usual manual macOS setup/signing steps.
