# XDG Base Directory Specification
# https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# Additional XDG-compliant directories (non-standard but useful)
export XDG_BIN_HOME="${XDG_BIN_HOME:-$HOME/.local/bin}"

# Suggested paths for language-specific packages (XDG-compliant)
export XDG_LIB_HOME="${XDG_LIB_HOME:-$HOME/.local/lib}"
