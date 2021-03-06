#!/bin/bash

# > system configuration script

# version:       1.2.0
# last modified: 20/02/2021

# -------------------------------------------------------------------------------------------------------

# > sudo test

if [ "$EUID" -eq 0 ]
  then echo "This script should NOT be run as root; run as current user and only enter password when asked."
  exit
fi

# -------------------------------------------------------------------------------------------------------

# > information
echo -e  "\n\e[104mSystem setup script [v1.1.1]\e[49m\n"

read -p "Configure the system and install essential packages? [Y/n] " -n 1 -r
echo
if [[ $REPLY =~ ^[Nn]$ ]]; then exit; fi

# -------------------------------------------------------------------------------------------------------

# > packages

echo -e  "\n\e[104mPackage and system configuration\e[49m\n"

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

echo -e "\nInstalling packages...\n"
sudo apt update
sudo apt install -y "${pkg_list[@]}"

# etc.

# bash history giu (hstr)
# https://github.com/dvorka/hstr
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

# > GNOME configuration (GNOME)

echo -e  "\n\e[104mSystem customization\e[49m\n"

# https://askubuntu.com/questions/971067/how-can-i-script-the-settings-made-by-gnome-tweak-tool

# install gnome-tweaks
echo -e "\nInstalling GNOME tweaks + extensions...\n"
sudo apt install gnome-tweaks -y
sudo apt install gnome-shell-extensions -y

# restart gnome-shell (can only be done once)
killall -3 gnome-shell && sleep 2
echo GNOME shell has been restarted.

# install themes
echo -e "\nInstalling theme and icons...\n"
sudo apt install arc-theme -y

# install icons
git clone https://github.com/daniruiz/flat-remix
mkdir -p ~/.icons && cp -r flat-remix/Flat-Remix* ~/.icons/
rm -rf flat-remix/

# apply configurations
echo -e "\nConfiguring system...\n"
#dconf write /org/gnome/desktop/interface/cursor-theme "'DMZ-Black'"

gsettings set org.gnome.shell enabled-extensions "['user-theme@gnome-shell-extensions.gcampax.github.com', 'alternate-tab@gnome-shell-extensions.gcampax.github.com', 'drive-menu@gnome-shell-extensions.gcampax.github.com', 'workspace-indicator@gnome-shell-extensions.gcampax.github.com']"

gsettings set org.gnome.shell.extensions.user-theme name 'Arc'
gsettings set org.gnome.desktop.interface icon-theme "Flat-Remix-Blue"
gsettings set org.gnome.desktop.interface gtk-theme 'Arc-Dark'
gsettings set org.gnome.desktop.interface cursor-theme 'DMZ-Black'

gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 32
gsettings set org.gnome.shell.extensions.dash-to-dock dock-position BOTTOM

gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 3600
gsettings set org.gnome.settings-daemon.plugins.power power-button-action 'suspend'
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'

# -------------------------------------------------------------------------------------------------------

# > fixes

# disable jack stick buzzing issue
# https://askubuntu.com/questions/1241617/ubuntu-20-04-after-last-update-speakers-are-buzzing-unless-i-open-the-sound-s
echo -e "\n# stop fucking buzzing\noptions snd-hda-intel power_save=0 power_save_controller=N" | sudo tee -a /home/androvich# gedit /etc/modprobe.d/alsa-base.conf

# disable UTC and use local time (for time sync between windows and linux)
timedatectl set-local-rtc 1 --adjust-system-clock

# -------------------------------------------------------------------------------------------------------

# > GitHub & SSH

echo -e  "\n\e[104mGitHub configuration\e[49m\n"

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
