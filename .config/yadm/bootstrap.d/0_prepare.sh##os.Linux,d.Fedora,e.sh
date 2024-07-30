#!/bin/bash

# https://mirrors.tuna.tsinghua.edu.cn/help/fedora/
# https://www.insidentally.com/articles/000028/
source $HOME/.config/yadm/utils.sh

system_type=$(uname -s)
if [ "$system_type" = "Linux" ]; then
	if grep -q "Fedora" /etc/os-release; then
    	note "prepare to bootstrap on Fedora"
	else
	    error "currently, only support bootstrap Fedora"
	fi
else
	error "should not bootstrap from this file"
fi

step "Installing XCode Command Line Tools..."

 "max_parallel_downloads=10
fastestmirror=True" | sudo tee -a /etc/dnf/dnf.conf

sudo dnf -y install dnf-plugins-core
sudo dnf config-manager --add-repo https://repo.vivaldi.com/stable/vivaldi-fedora.repo
sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
printf "[vscode]\nname=packages.microsoft.com\nbaseurl=https://packages.microsoft.com/yumrepos/vscode/\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc\nmetadata_expire=1h" | sudo tee -a /etc/yum.repos.d/vscode.repo

sudo dnf upgrade --refresh -y
sudo dnf update

sudo dnf -y install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
