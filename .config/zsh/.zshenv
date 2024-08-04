#
# All shell startup stuff
#

export LANG="zh_CN.UTF-8"

if [[ "$(uname)" == "Darwin" ]]; then
    if [[ -x /opt/homebrew/bin/brew ]]; then
    	eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -x /usr/local/bin/brew ]]; then
    	eval "$(/usr/local/bin/brew shellenv)"
    fi
fi

export EDITOR="nvim"

# Add paths to PATH
path+=(
  $HOME/.local/bin
  /usr/local/bin
  $path
)

export PATH
. "/Users/jensen/Projects/site-package/cargo/env"
