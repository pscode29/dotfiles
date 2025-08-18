⁠ ## Quick Setup

### 1. Initial Setup
 ⁠bash
# Make scripts executable
chmod +x setup.sh cleanup.sh

# Run complete setup
./setup.sh


⁠ ### 2. Post-Setup Configuration
<!-- Do this step in Ghostty -->

**Tmux Plugin Installation:**
 ⁠bash
# Start tmux and install plugins
tmux
# Press: Ctrl+a then I (capital i)


⁠ **Neovim Setup:**
 ⁠bash
# Open Neovim and run:
:Lazy sync
:MasonInstallAll


⁠ **Restart Terminal:**
 ⁠bash
# Source new shell configuration
source ~/.zshrc
# Or restart terminal completely


## What Gets Installed

### Package Managers
- **Homebrew** - macOS package manager
- **NVM** - Node.js version manager
- **uv** - Python package and project manager

### Development Tools
- **Neovim** - Text editor with NvChad configuration
- **Tmux** - Terminal multiplexer with custom config
- **Starship** - Cross-shell prompt
- **GNU Stow** - Symlink farm manager for dotfiles
- **ripgrep** - Fast text search tool
- **fzf** - Fuzzy finder

### Applications
- **Ghostty** - GPU-accelerated terminal emulator
- **JetBrains Mono Nerd Font** - Programming font with icons

### Languages & Runtimes
- **Python** (latest via uv)
- **Node.js** (latest via NVM)

## Directory Structure


dotfiles/
├── .config/
│   ├── nvim/           # Neovim configuration (NvChad)
│   ├── starship.toml   # Starship prompt config
│   └── ...
├── vscode/             # VS Code settings & extensions
│   ├── settings.json
│   ├── keybindings.json
│   └── extensions.txt
├── .tmux.conf          # Tmux configuration
├── .zshrc              # Zsh shell configuration
├── setup.sh            # Main setup script
├── cleanup.sh          # Complete removal script
└── README.md           # This file


⁠ ## Usage Guide

### Adding New Tmux Plugins
1. Edit `.tmux.conf` and add plugin line:
    ⁠bash
   set -g @plugin 'plugin-name'
   
⁠ 2. Reload tmux config and install:
    ⁠bash
   tmux source-file ~/.tmux.conf
   # In tmux: Ctrl+a + I
   

⁠ ### Adding Language Support to Neovim
1. Add LSP server and parser to `.config/nvim/lua/plugins/init.lua`:
    ⁠lua
   -- In ensure_installed tables
   ensure_installed = {
     "language-server-name",
     "language-parser-name",
   }
   
⁠ 2. Configure LSP in `.config/nvim/lua/configs/lspconfig.lua`
3. Run `:MasonInstallAll` in Neovim

### Managing Python Projects
 ⁠bash
# Create new project
uv init my-project
cd my-project

# Add dependencies
uv add requests

# Run Python scripts
uv run script.py


⁠ ### Managing Node.js Versions
 ⁠bash
# Install specific version
nvm install 18.17.0

# Use specific version
nvm use 18.17.0

# Set default version
nvm alias default node


⁠ ## Reset Everything
 ⁠bash
# Complete system cleanup (removes all configurations)
./cleanup.sh


⁠ ## Maintenance

### Regular Updates
 ⁠bash
# Update Homebrew packages
brew update && brew upgrade

# Update NVM and Node.js
nvm install node --reinstall-packages-from=node

# Update uv
uv self update

# Update Neovim plugins
# In Neovim: :Lazy update
```
```