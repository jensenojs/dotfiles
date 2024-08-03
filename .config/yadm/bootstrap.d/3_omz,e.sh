#!/bin/bash

source ${HOME}/.config/yadm/utils.sh

ZSH_USERS_URL="https://github.com/zsh-users"

if directory_exists $ZSH; then
	info "oh-my-zsh is already installed"
else
	step "Installing oh-my-zsh and its plugin ..."

	if [ -z "$XDG_DATA_HOME" ]; then
		error "should set XDG_DATA_HOME before install oh-my-zsh"
	else
		export ZSH="$XDG_DATA_HOME/omz"
		sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
	fi
fi

if [ -z "$ZSH_CUSTOM" ]; then
	export ZSH_CUSTOM="$ZSH/custom"
	info "setting ZSH_CUSTOM as $ZSH_CUSTOM"
fi

function omz_install_plugin() {
	declare url="$1"
	declare plugin="$2"

	if [[ $url == "$ZSH_USERS_URL" ]]; then
		run git clone --depth 1 "$url/$plugin" \
			"${ZSH_CUSTOM}/plugins/$plugin"
	else
		run git clone --depth 1 "$url" \
			"${ZSH_CUSTOM}/plugins/$plugin"
	fi
}

# themes
if directory_exists $ZSH_CUSTOM/themes/powerlevel10k; then
	info "powerlevel10k is already installed"
else
	info "install powerlevel10k"
	run git clone --depth 1 https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k
fi

# zsh-autosuggestions
# https://github.com/zsh-users/zsh-autosuggestions
if directory_exists $ZSH_CUSTOM/plugins/zsh-autosuggestions; then
	info "zsh-autosuggestions is already installed"
else
	info "install zsh-autosuggestions"
	omz_install_plugin $ZSH_USERS_URL "zsh-autosuggestions"
fi

# zsh-syntax-highlighting
# https://github.com/valentinocossar/vscode
if directory_exists $ZSH_CUSTOM/plugins/zsh-syntax-highlighting; then
	info "zsh-syntax-highlighting is already installed"
else
	info "install zsh-syntax-highlighting"
	omz_install_plugin $ZSH_USERS_URL "zsh-syntax-highlighting"
fi

# zsh-you-should-use
# https://github.com/MichaelAquilina/zsh-you-should-use
if directory_exists $ZSH_CUSTOM/plugins/you-should-use; then
	info "zsh-you-should-use is already installed"
else
	info "install zsh-you-should-use"
	omz_install_plugin "https://github.com/MichaelAquilina/zsh-you-should-use.git" \
		"you-should-use"
fi

# vscode
# https://github.com/valentinocossar/vscode
if directory_exists $ZSH_CUSTOM/plugins/vscode; then
	info "zsh-vscode is already installed"
else
	info "install zsh-vscode"
	omz_install_plugin "https://github.com/valentinocossar/vscode.git" \
		"vscode"
fi

# zsh-vi-mode, but i am not use
# https://github.com/jeffreytse/zsh-vi-mode
if directory_exists $ZSH_CUSTOM/plugins/zsh-vi-mode; then
	info "zsh-vi-mode is already installed"
else
	info "install zsh-vi-mode"
	omz_install_plugin "https://github.com/jeffreytse/zsh-vi-mode" \
		"zsh-vi-mode"
fi

# fzf-tab
# https://github.com/Aloxaf/fzf-tab?tab=readme-ov-file#fzf-tab
if directory_exists $ZSH_CUSTOM/plugins/fzf-tab; then
	info "fzf-tab is already installed"
else
	info "install zsh-fzf-tab"
	omz_install_plugin "https://github.com/Aloxaf/fzf-tab" \
		"fzf-tab"
fi
