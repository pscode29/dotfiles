## Step 1: Install softwares and stow dotfiles
```
./install.sh
```

## Step 2: Update NvChad
- Open Neovim
- Run `:Lazy sync`
- Run `:MasonInstallAll`

That's all.

## Additional Info

# How to install a new Tmux plugin
- Update .tmux.conf with new plugin detail
- Run
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
