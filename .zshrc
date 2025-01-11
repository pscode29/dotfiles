###############################################################################
# Put homebrew installed softwares in path, never had to do it before.
###############################################################################
export PATH="/opt/homebrew/bin:$PATH"  # For Apple Silicon
export PATH="/usr/local/bin:$PATH"    # For Intel Macs
###############################################################################
# pyenv settings:
###############################################################################
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init --path)"
  eval "$(pyenv init -)"
fi
###############################################################################
alias ga="git add"
alias gc="git commit -m"
alias gs="git status"
alias gp="git push origin -u HEAD"
alias gpom="git pull origin main"
# Delete all local branches except main
alias gdab="git branch | grep -v 'main' | xargs git branch -D"
###############################################################################
# Starship settings:
###############################################################################
eval "$(starship init zsh)"
###############################################################################
# SDKMAN - Below is auto added by SDKMAN
###############################################################################
#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
###############################################################################
