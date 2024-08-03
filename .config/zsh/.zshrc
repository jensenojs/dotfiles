# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.config/zsh/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
export ZSH_THEME="powerlevel10k/powerlevel10k"

# export HISTFILE=~/.zsh_history
mkdir -p "${XDG_STATE_HOME}./zsh"
export HISTFILE="${XDG_STATE_HOME}/zsh/history"
export HISTSIZE=1000
export SAVEHIST=10000


# cd can be omitted for changing directory
setopt autocd 
# Allow extended glob for matching files
setopt extendedglob
# Sort files numerically
setopt numericglobsort
# Do not beep
setopt nobeep
# Always append history
setopt histappend
# Do not enter command lines into the history list if they are duplicatese of the previous event
setopt HIST_SAVE_NO_DUPS
# Ignore commands that start with space
setopt hist_ignore_space
# Share command history data
setopt share_history
# When HISTFILE size exceeds, delete duplicates first
setopt hist_expire_dups_first

# Load Oh My ZSH
source $ZDOTDIR/omz

# To customize prompt, run `p10k configure` or edit ~/.config/zsh/.p10k.zsh.
source $ZDOTDIR/.p10k.zsh

# Load aliases
source $ZDOTDIR/alias

# Load specific config for environment
source $ZDOTDIR/zshrc_ext

# set fzf config
[[ ! -f ~/.config/fzf/config ]] || source ~/.config/fzf/config

