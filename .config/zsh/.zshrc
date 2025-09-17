# ~/.config/zsh/.zshrc
#
# This file is sourced by interactive shells
# Configuration is modularized in zshrc.d/ directory
#
# To debug startup time, uncomment the following lines:
# zmodload zsh/zprof

# Load all interactive configuration modules from zshrc.d/
# Files are loaded in alphabetical order (use numeric prefixes to control order)
if [ -d "${ZDOTDIR:-$HOME/.config/zsh}/zshrc.d" ]; then
  for rc_file in "${ZDOTDIR:-$HOME/.config/zsh}"/zshrc.d/*.zsh(N); do
    [ -r "$rc_file" ] && source "$rc_file"
  done
  unset rc_file
fi

# ... (at the end of file) ...
# zprof