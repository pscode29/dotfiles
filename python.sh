# uv is the new hot thing to manage Python and Python things.
# install uv, I am not using brew to install as I want to follow uv guideline
# to manage uv and potentially uninsatll it the official way later.
#
# Install uv:
curl -LsSf https://astral.sh/uv/install.sh | sh

# Update uv:
# uv self update

# Uninstall uv:
# Cleanup stored data: 
# uv cache clean
# rm -r "$(uv python dir)"
# rm -r "$(uv tool dir)"

# Remove uv and uvx binaries:
# rm ~/.local/bin/uv ~/.local/bin/uvx

