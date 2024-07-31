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

# strange sth that this still needed to let zsh find .zshrc in this folder
export ZDOTDIR=~/.config/zsh

# Set Oh-My-Zsh folder
export ZSH=~/.config/omz
export ZSH_THEME="powerlevel10k/powerlevel10k"

export EDITOR="nvim"

# XDG Dirs
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"


# Add paths to PATH
path+=(
  $HOME/bin
  /usr/local/bin
  $path
)

export PATH
