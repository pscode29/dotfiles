#!/bin/bash

set -e

DOTFILES_DIR="${HOME}/dotfiles"
TMUX_PLUGIN_DIR="${HOME}/.tmux/plugins/tpm"
NVM_VERSION="v0.40.3"
VSCODE_CONFIG="${DOTFILES_DIR}/.config/vscode"
VSCODE_DIR_MACOS="${HOME}/Library/Application Support/Code/User"
 

# --- System Info ---
OS_TYPE=""
MACOS_VERSION=""
ARCHITECTURE=""

######################################################################
# Logger
######################################################################

log() {
    echo -e "\033[32m[INFO]\033[0m $1"
}

warn() {
    echo -e "\033[33m[WARN]\033[0m $1"
}

error() {
    echo -e "\033[31m[ERROR]\033[0m $1" >&2
    exit 1
}

success() {
    echo -e "\033[32m[SUCCESS]\033[0m $1"
}
######################################################################

detect_system_info() {
  if [[ "$(uname)" != "Darwin" ]]; then
    error "❌ This setup script is intended for macOS only."
    exit 1
  fi

  OS_TYPE="macOS"
  MACOS_VERSION=$(sw_vers -productVersion)
  ARCHITECTURE=$(uname -m)

  log "🖥️ Detected: $OS_TYPE $MACOS_VERSION ($ARCHITECTURE)"
}

# --- VS Code ---
install_vscode() {
  if [ -d "/Applications/Visual Studio Code.app" ]; then
    warn "VS Code is already installed."
    return
  fi

  log "📦 Downloading Visual Studio Code..."
  local url="https://code.visualstudio.com/sha/download?build=stable&os=darwin-universal"
  curl -L "$url" -o /tmp/VSCode.zip

  log "📂 Installing to /Applications..."
  unzip -q /tmp/VSCode.zip -d /Applications
  rm -f /tmp/VSCode.zip
  success "VS Code installed successfully."

  log "Setting up 'code' CLI..."
  sudo ln -sf "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" /usr/local/bin/code

  log "Copying VSCode settings and keybindings..."
  
  if [[ ! -d "$VSCODE_CONFIG" ]]; then
      warn "VS Code directory not found, skipping VS Code settings and keybindings setup"
      return
  fi
  
  log "Setting up VS Code settings dir..."
  mkdir -p "$VSCODE_DIR_MACOS"
  
  # Create individual symlinks for VS Code files
  [[ -f "${VSCODE_CONFIG}/settings.json" ]] && ln -sf "${VSCODE_CONFIG}/settings.json" "${VSCODE_DIR_MACOS}/settings.json"
  [[ -f "${VSCODE_CONFIG}/keybindings.json" ]] && ln -sf "${VSCODE_CONFIG}/keybindings.json" "${VSCODE_DIR_MACOS}/keybindings.json"
  
  success "VS Code settings and keybindings set up successfully."

  log "Installing VS Code extensions..."
  local extension_file="${VSCODE_CONFIG}/extensions.txt"
    
  if [[ ! -f "$extension_file" ]]; then
      warn "VS Code extensions file not found, skipping extension installation"
      return
  fi
  
  log "Installing VS Code extensions..."
  while IFS= read -r extension || [[ -n "$extension" ]]; do
      if [[ ! "$extension" =~ ^#.*$ && -n "$extension" ]]; then
          log "Installing: $extension"
          code --install-extension "$extension" --force 2>/dev/null || warn "Failed to install $extension"
      fi
  done < "$extension_file"
  
  success "VS Code extensions installed"
}

uninstall_vscode() {

  log "🗑️ Uninstalling Visual Studio Code..."
  sudo rm -rf "/Applications/Visual Studio Code.app"
  sudo rm -f /usr/local/bin/code

  log "🧹 Removing user data..."
  rm -rf ~/Library/Application\ Support/Code
  rm -rf ~/Library/Caches/com.microsoft.VSCode
  rm -rf ~/Library/Preferences/com.microsoft.VSCode*
  rm -rf ~/Library/Saved\ Application\ State/com.microsoft.VSCode.*
  rm -rf ~/.vscode

  [[ -L "${VSCODE_DIR_MACOS}/settings.json" ]] && rm "${VSCODE_DIR_MACOS}/settings.json"
  [[ -L "${VSCODE_DIR_MACOS}/keybindings.json" ]] && rm "${VSCODE_DIR_MACOS}/keybindings.json"
    
  success "VS Code settings and keybindings removed."

  success "VS Code fully removed."
}

# --- Fonts: JetBrains Mono Nerd Font ---
install_fonts() {
  FONT_NAME="JetBrainsMono"
  FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
  FONT_DIR="$HOME/Library/Fonts"

  log "🔤 Installing $FONT_NAME Nerd Font..."

  if ls "$FONT_DIR" | grep -qi "$FONT_NAME"; then
    warn "$FONT_NAME already installed."
    return
  fi

  TMP_ZIP="/tmp/${FONT_NAME}.zip"
  curl -L "$FONT_URL" -o "$TMP_ZIP"
  unzip -q "$TMP_ZIP" -d /tmp/${FONT_NAME}_unzipped
  cp /tmp/${FONT_NAME}_unzipped/*.ttf "$FONT_DIR"

  rm -rf "$TMP_ZIP" /tmp/${FONT_NAME}_unzipped
  success "$FONT_NAME installed to $FONT_DIR"
}

uninstall_fonts() {
  FONT_NAME="JetBrainsMono"
  FONT_DIR="$HOME/Library/Fonts"

  log "🗑️ Removing $FONT_NAME Nerd Fonts..."
  find "$FONT_DIR" -iname "$FONT_NAME*.ttf" -exec rm {} \;

  success "Fonts removed from $FONT_DIR"
}

# --- Terminals & CLI Tools ---
install_terminal_tools() {
  log "🔧 Installing terminal tools..."

  # Ghostty
  local dmg_path="/tmp/Ghostty.dmg"
  local mount_point="/Volumes/Ghostty"

  if [ -d "/Applications/Ghostty.app" ]; then
    warn "Ghostty already installed."
    return
  fi

  log "📦 Downloading Ghostty..."
  curl -L https://github.com/ghostty-org/ghostty/releases/download/tip/Ghostty.dmg -o "$dmg_path"

  log "📂 Mounting Ghostty.dmg..."
  hdiutil attach "$dmg_path" -nobrowse -quiet

  log "🚚 Copying Ghostty to /Applications..."
  cp -R "$mount_point/Ghostty.app" /Applications

  log "📤 Unmounting Ghostty.dmg..."
  hdiutil detach "$mount_point" -quiet

  rm -f "$dmg_path"
  success "Ghostty installed successfully."

  # Starship
  if ! command -v starship >/dev/null; then
    log "✨ Installing Starship prompt..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y
    echo 'eval "$(starship init zsh)"' >> ~/.zshrc
    success "Starship installed."
  else
    warn "Starship already installed."
  fi

  # tmux
  if ! command -v tmux >/dev/null; then
    log "📦 Installing tmux..."
    curl -L https://github.com/tmux/tmux/releases/latest/download/tmux.tar.gz -o /tmp/tmux.tar.gz
    tar -xzf /tmp/tmux.tar.gz -C /tmp
    cd /tmp/tmux*/ && ./configure && make && sudo make install
    success "tmux installed."
  else
    warn "tmux already installed."
  fi

  # tmux plugin manager
  if [ ! -d "$TMUX_PLUGIN_DIR" ]; then
    log "📥 Installing tmux plugin manager..."
    git clone https://github.com/tmux-plugins/tpm "$TMUX_PLUGIN_DIR"
    success "tmux plugin manager installed."
  else
    warn "tmux plugin manager already installed."
  fi

  # GNU stow
  if ! command -v stow >/dev/null; then
    log "📦 Installing GNU stow..."
    curl -LO https://ftpmirror.gnu.org/stow/stow-latest.tar.gz
    tar -xzf stow-latest.tar.gz
    cd stow-* && ./configure && make && sudo make install
    success "stow installed."
  else
    warn "stow already installed."
  fi

  # ripgrep
  if ! command -v rg >/dev/null; then
    log "📦 Installing ripgrep..."
    curl -LO https://github.com/BurntSushi/ripgrep/releases/latest/download/ripgrep-13.0.0-x86_64-apple-darwin.tar.gz
    tar -xzf ripgrep-*-apple-darwin.tar.gz
    sudo cp ripgrep-*/rg /usr/local/bin/
    success "ripgrep installed."
  else
    warn "ripgrep already installed."
  fi

  # fzf
  if [ ! -d "${HOME}/.fzf" ]; then
    log "🔍 Installing fzf..."
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --all
    success "fzf installed."
  else
    warn "fzf already installed."
  fi

  # Neovim
  if ! command -v nvim >/dev/null; then
    log "📦 Installing Neovim..."
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-macos.tar.gz
    tar xzf nvim-macos.tar.gz
    sudo mv nvim-macos/bin/nvim /usr/local/bin/
    success "Neovim installed."
  else
    warn "Neovim already installed."
  fi
}

uninstall_terminal_tools() {
  log "🗑️ Uninstalling terminal tools..."

  sudo rm -rf /Applications/Ghostty.app
  rm -f /usr/local/bin/starship
  rm -f /usr/local/bin/tmux
  rm -rf "$TMUX_PLUGIN_DIR"
  rm -f /usr/local/bin/stow
  rm -f /usr/local/bin/rg
  rm -rf ~/.fzf
  rm -f /usr/local/bin/nvim

  success "Terminal tools removed."
}

setup_macos() {
    log "Configuring macOS settings..."
    
    # Key repeat settings
    defaults write -g InitialKeyRepeat -int 12
    defaults write -g KeyRepeat -int 2
    defaults write -g ApplePressAndHoldEnabled -bool false
    
    success "macOS settings configured"
}

reset_macos_settings() {
    log "Resetting macOS settings to defaults..."
    
    # Reset key repeat settings to macOS defaults
    defaults delete -g InitialKeyRepeat 2>/dev/null || true
    defaults delete -g KeyRepeat 2>/dev/null || true
    defaults delete -g ApplePressAndHoldEnabled 2>/dev/null || true
    
    success "macOS settings reset to defaults"
}

stow_dotfiles() {
    if [[ ! -d "$DOTFILES_DIR" ]]; then
        error "Dotfiles directory not found: $DOTFILES_DIR"
    fi
    
    log "Stowing dotfiles..."
    cd "$DOTFILES_DIR"
    
    # Try stowing, if conflicts occur use --adopt
    if ! stow . 2>/dev/null; then
        warn "Stow conflicts detected. Using --adopt to resolve conflicts"
        stow --adopt .
    fi
    
    success "Dotfiles stowed successfully"
}

unstow_dotfiles() {
    if [[ ! -d "$DOTFILES_DIR" ]]; then
        warn "Dotfiles directory not found, skipping unstowing"
        return
    fi
    
    log "Unstowing dotfiles..."
    cd "$DOTFILES_DIR"
    stow -D . 2>/dev/null || warn "Some dotfiles may not have been stowed"
    success "Dotfiles unstowed"
}

# --- Composite: Install All / Uninstall All ---
install_all() {
  setup_macos
  install_fonts
  install_terminal_tools
  install_vscode
  stow_dotfiles
  }
  

uninstall_all() {
  reset_macos_settings
  uninstall_fonts
  uninstall_terminal_tools
  uninstall_vscode
  unstow_dotfiles
}

# --- Main CLI Handler ---
main() {
  detect_system_info

  if [[ "$#" -ne 2 ]]; then
    error "❌ Usage: $0 --install|--uninstall <defaults|fonts|terminal|vscode|dotfiles|all>"
    exit 1
  fi

  ACTION=$1
  TARGET=$2

  case "$ACTION" in
    --install)
      case "$TARGET" in
        defaults) setup_macos ;;
        fonts) install_fonts ;;
        terminal) install_terminal_tools ;;
        vscode) install_vscode ;;
        dotfiles) stow_dotfiles ;;
        all) install_all ;;
        *) error "❌ Unknown install target: $TARGET"; exit 1 ;;
      esac
      ;;
    --uninstall)
      case "$TARGET" in
        defaults) reset_macos_settings ;;
        fonts) uninstall_fonts ;;
        terminal) uninstall_terminal_tools ;;
        vscode) uninstall_vscode ;;
        dotfiles) unstow_dotfiles ;;
        all) uninstall_all ;;
        *) error "❌ Unknown uninstall target: $TARGET"; exit 1 ;;
      esac
      ;;
    *)
      error "❌ Unknown action: $ACTION"
      log "Usage: $0 --install|--uninstall <defaults|fonts|terminal|vscode|dotfiles|all>"
      exit 1
      ;;
  esac
}

main "$@"
