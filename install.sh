# Exit immediately if a command exits with a non-zero status
set -e

# Variables
DOTFILES_DIR=~/dotfiles
CONFIG_DIR=~/.config
TMUX_CONF=~/.tmux.conf
ZSHRC=~/.zshrc
BACKUP_SUFFIX="_dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
BACKUP_PATTERN="_dotfiles_backup_*"
TMUX_PLUGIN_DIR=~/.tmux/plugins/tpm

log() {
	echo "\033[32m[INFO]\033[0m $1"
}

error() {
	echo "\033[31m[ERROR]\033[0m $1" >&2
	exit 1
}

# Remove old backups
log "Removing older backups..."
find ~ -maxdepth 1 -name "*$BACKUP_PATTERN" -exec rm -rf {} +
log "Older backups removed."

# Backup and clean old configuration
log "Backing up and cleaning existing configurations..."
[[ -d "$CONFIG_DIR" ]] && mv "$CONFIG_DIR" "$CONFIG_DIR$BACKUP_SUFFIX"
[[ -f "$TMUX_CONF" ]] && mv "$TMUX_CONF" "$TMUX_CONF$BACKUP_SUFFIX"
[[ -f "$ZSHRC" ]] && mv "$ZSHRC" "$ZSHRC$BACKUP_SUFFIX"
rm -rf ~/.local/state/nvim ~/.local/share/nvim ~/.tmux

# Create fresh configuration directory
mkdir -p "$CONFIG_DIR"

# Install dependencies with Homebrew
log "Installing dependencies via Homebrew..."
brew install neovim starship tmux stow ripgrep fzf
brew install --cask ghostty

# Install Tmux Plugin Manager
log "Installing Tmux Plugin Manager..."
if [[ ! -d "$TMUX_PLUGIN_DIR" ]]; then
  git clone https://github.com/tmux-plugins/tpm "$TMUX_PLUGIN_DIR"
else
  log "Tmux Plugin Manager is already installed."
fi

# Stow dotfiles
if [[ -d "$DOTFILES_DIR" ]]; then
  log "Stowing dotfiles..."
  cd "$DOTFILES_DIR"
  stow .
else
  error "Dotfiles directory not found: $DOTFILES_DIR"
fi

# Optionally, unstow dotfiles
# log "Unstowing dotfiles..."
# stow -D .

cd ~
log "Setup completed successfully."
