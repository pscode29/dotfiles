# Assumption: Brew is installed in the system 
# Load brew
eval "$(/opt/homebrew/bin/brew shellenv)"

cd ~
# Backup and clean
mv .config .config_backup
mv .tmux.conf .tmux.conf_backup
mv .zshrc .zshrc_backup
rm -rf ~/.local/state/nvim
rm -rf ~/.local/share/nvim
rm -rf .tmux

mkdir .config

# Brew install
brew install neovim starship tmux stow ripgrep
brew install --cask alacritty

# Install tmux plugin manager
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# stow everything
cd dotfiles
stow .
# unstow everything if needed
# stow -D .
cd ~
