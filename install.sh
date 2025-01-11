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
find ~ -maxdepth 1 -name "*$BACKUP_PATTERN" -exec rm -rf {} + || error "Failed to remove older backups."
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
brew install neovim starship tmux stow ripgrep || error "Failed to install packages."
brew install --cask ghostty || error "Failed to install ghostty."

# Install Tmux Plugin Manager
log "Installing Tmux Plugin Manager..."
if [[ ! -d "$TMUX_PLUGIN_DIR" ]]; then
  git clone https://github.com/tmux-plugins/tpm "$TMUX_PLUGIN_DIR" || error "Failed to clone TPM."
else
  log "Tmux Plugin Manager is already installed."
fi

# Stow dotfiles
if [[ -d "$DOTFILES_DIR" ]]; then
  log "Stowing dotfiles..."
  cd "$DOTFILES_DIR" || error "Failed to change directory to $DOTFILES_DIR."
  stow . || error "Failed to stow dotfiles."
else
  error "Dotfiles directory not found: $DOTFILES_DIR"
fi

# Optionally, unstow dotfiles
# log "Unstowing dotfiles..."
# stow -D .

cd ~ || error "Failed to return to the home directory."

# Check and start tmux session if not running
if ! tmux info &>/dev/null; then
  log "No tmux session detected. Starting a new tmux session..."
  tmux new-session -d -s auto_tmux_session || error "Failed to start tmux session."
else
  log "Tmux is already running."
fi

# Reload tmux configuration
log "Reloading tmux configuration..."
tmux source-file "$TMUX_CONF" || error "Failed to reload tmux configuration."

# Install tmux plugins
log "Installing tmux plugins..."
tmux run-shell "$TMUX_PLUGIN_DIR/bin/install_plugins" || error "Failed to install tmux plugins."

log "Tmux plugins installed successfully."

# Exit tmux server
log "Exiting tmux server..."
tmux kill-server || error "Failed to exit tmux server."

log "Tmux server exited successfully."
log "Setup completed successfully."
