#!/bin/bash

# system configuration script

# version:       2.0.0
# last modified: 09/03/2022

# -------------------------------------------------------------------------------------------------------

# sudo test

if [ "$EUID" -eq 0 ]
	then echo "This script should NOT be run as root; run as current user and only enter password when asked."
	exit
fi

# -------------------------------------------------------------------------------------------------------

# information

echo -e  "\n\e[104mSystem setup script\e[49m\n"

read -p "Configure the system? [Y/n] " -n 1 -r
echo
if [[ $REPLY =~ ^[Nn]$ ]]; then exit; fi

# -------------------------------------------------------------------------------------------------------

# packages

echo -e  "\n\e[104mPackage and system configuration\e[49m\n"

# general
pkg_list=( 
	build-essential
	cmake
	git
	vim
	net-tools
	htop
	cpufrequtils
	xclip
	curl
	software-properties-common
	apt-transport-https
	wget
	sed
)

echo -e "\nInstalling general packages...\n"
sudo apt update
sudo apt install -y "${pkg_list[@]}"

# bash history GUI (hstr)
# https://github.com/dvorka/hstr
echo -e "\nInstalling history GUI (hstr)...\n"
sudo add-apt-repository ppa:ultradvorka/ppa && sudo apt-get update && sudo apt-get install hstr && hstr --show-configuration >> ~/.bashrc && . ~/.bashrc

# visual studio code
echo -e "\nInstalling visual code...\n"
#sudo snap install code --classic
wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
sudo apt update
sudo apt install code

# system update
echo -e "\nUpdating system...\n"
sudo apt update
sudo apt upgrade -y

# -------------------------------------------------------------------------------------------------------

# desktop environment

echo -e  "\n\e[104mDesktop environemnt\e[49m\n"

echo -e "\nSetting up Regolith...\n"
sudo add-apt-repository ppa:regolith-linux/stable
sudo apt install regolith-desktop-standard

# -------------------------------------------------------------------------------------------------------

# system configuration

echo -e  "\n\e[104mSystem configuration\e[49m\n"

# apply GNOME settings
# https://askubuntu.com/questions/971067/how-can-i-script-the-settings-made-by-gnome-tweak-tool

echo -e "\nConfiguring GNOME...\n"

gsettings set org.gnome.desktop.interface cursor-theme 'DMZ-Black'

gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 3600
gsettings set org.gnome.settings-daemon.plugins.power power-button-action 'suspend'
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'

# disable UTC and use local time (for time sync between windows and linux)
timedatectl set-local-rtc 1 --adjust-system-clock

# disable jack stick buzzing issue
# https://askubuntu.com/questions/1241617/ubuntu-20-04-after-last-update-speakers-are-buzzing-unless-i-open-the-sound-s
# echo -e "\n# stop fucking buzzing\noptions snd-hda-intel power_save=0 power_save_controller=N" | sudo tee -a /home/androvich# gedit /etc/modprobe.d/alsa-base.conf

# -------------------------------------------------------------------------------------------------------

# GitHub/SSH

echo -e  "\n\e[104mGitHub/SSH configuration\e[49m\n"

# https://help.github.com/en/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent
# https://help.github.com/en/github/authenticating-to-github/adding-a-new-ssh-key-to-your-github-account
# https://stackoverflow.com/questions/1885525/how-do-i-prompt-a-user-for-confirmation-in-bash-script

email="martinandrovich@gmail.com"
name="Martin Androvich"

echo -e "\nConfiguring git user credentials...\n"
git config --global user.email $email
git config --global user.name $name

read -p "Setup SSH key? [Y/n] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then

	echo -e "\nGenerating SSH key...\n"
	ssh-keygen -t rsa -b 4096 -C $email
	eval "$(ssh-agent -s)"
	ssh-add ~/.ssh/id_rsa
	xclip -sel clip < ~/.ssh/id_rsa.pub
	echo "The SSH key has been copied to the clipboard."

fi
