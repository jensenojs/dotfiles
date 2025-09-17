# ~/.config/zsh/.zshenv
#
# This file is ALWAYS sourced by all zsh instances (login, interactive, scripts)
# Keep it minimal - only environment variables should go here
#
# Configuration is modularized in env.d/ directory

# Set locale
export LANG="zh_CN.UTF-8"

# Load all environment modules from env.d/
# Files are loaded in alphabetical order (use numeric prefixes to control order)
if [ -d "${ZDOTDIR:-$HOME/.config/zsh}/env.d" ]; then
  for env_file in "${ZDOTDIR:-$HOME/.config/zsh}"/env.d/*.zsh(N); do
    [ -r "$env_file" ] && source "$env_file"
  done
  unset env_file
fi
