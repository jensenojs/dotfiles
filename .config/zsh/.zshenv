#
# All shell startup stuff
#

export LANG="zh_CN.UTF-8"

# XDG base directories (defaults)
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# Homebrew (macOS) - idempotent
if [[ "$(uname)" == "Darwin" ]]; then
  if [[ -x /opt/homebrew/bin/brew ]]; then
    _BREW="/opt/homebrew/bin/brew"
  elif [[ -x /usr/local/bin/brew ]]; then
    _BREW="/usr/local/bin/brew"
  fi
  if [[ -n "${_BREW:-}" ]]; then
    _BREW_PREFIX="$($_BREW --prefix 2>/dev/null)"
    if [[ -z "${HOMEBREW_PREFIX:-}" ]] || [[ ":$PATH:" != *":${_BREW_PREFIX}/bin:"* ]]; then
      eval "$($_BREW shellenv)"
    fi
    unset _BREW_PREFIX
  fi
  unset _BREW
fi

export EDITOR="nvim"

# Add paths to PATH
typeset -U path
# Prepend only if missing
if [[ -d "$HOME/.local/bin" ]] && [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
  path=("$HOME/.local/bin" $path)
fi
if [[ -d "/usr/local/bin" ]] && [[ ":$PATH:" != *":/usr/local/bin:"* ]]; then
  path=("/usr/local/bin" $path)
fi
export PATH
