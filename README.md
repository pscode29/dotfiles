# Install and stow

```
./install.sh
```

# Install Mason plugins

- Run `:MasonInstallAll` in Neovim

# Install Tmux plugins

```
cd ~
# Run tmux
tmux
# Source tmux conf
tmux source-file .tmux.conf
# Install plugins
<C-a> I
```

# How to add a new language support
- Add the language server using Mason and parser using Treesitter. Use the
ensure installed options in `plugins/init.lua`
- Add the LSP configuration in `configs/lspconfig.lua`
- Run `:MasonInstallAll` now
