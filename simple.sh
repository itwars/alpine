#!/bin/bash

function box() {
  title="│ $* │"
  edgeTop=$(echo "$title" | sed 's/./─/g')
  edgeBot=$(echo "$title" | sed 's/./─/g')
  echo $edgeTop | sed s/─/┌/1 | sed s/─$/┐/
  echo $title
  echo $edgeBot | sed s/─/└/1 | sed s/─$/┘/
}

function update_repositories() {
  box "Add community repo + update"
  version=$(cat /etc/alpine-release | cut -d'.' -f1,2)
cat << EOF > /etc/apk/repositories
https://dl-cdn.alpinelinux.org/alpine/v$version/main
https://dl-cdn.alpinelinux.org/alpine/v$version/community
EOF
   apk upgrade
}

function setup() 
{

box "setup locales"
apk add openrc-settingsd musl-locales dbus polkit
rc-update add dbus
rc-update add openrc-settingsd
rc-update add polkit

rc-service dbus start
rc-service polkit start
rc-service openrc-settingsd start

alreadyset=`./setlocale-alpinelinux.sh -a | grep FR | wc -l`
if [ $alreadyset -eq 0 ] 
then
  ./setlocale-alpinelinux.sh -l fr_FR.utf8
  ./setlocale-alpinelinux.sh -v fr
  ./setlocale-alpinelinux.sh -x fr
  reboot
fi

box "Install plasma + kde"
setup-xorg-base

box "setup plasma"
setup-desktop plasma
apk add plasma


box "setup wayland"
apk add xf86-video-amdgpu
# allowed you to install new themes !!!
apk add frameworkintegration5 

rc-update add sddm
rc-update add fuse
rc-update add elogind

box "Install networkmanager"

apk add networkmanager networkmanager-wifi iwd

addgroup vrabah plugdev                                  
rc-update add networkmanager boot                  
rc-update add iwd boot
rc-update del networking boot                        
rc-update del wpa_supplicant boot


cat << EOF > /etc/NetworkManager/NetworkManager.conf
[main]                                               
dhcp=internal                                        
plugins=ifupdown,keyfile

[ifupdown]                                           
managed=true

[device]                                             
wifi.scan-rand-mac-address=no                        
wifi.backend=iwd                          

[connection]
ipv6.ip6-privacy=2" > /etc/NetworkManager/NetworkManager.conf

EOF
}

function install_misc_kde() {
  box "install misc KDE"
  apk add \
    vulkan-tools \
    opencl \
    wayland \
    mesa-vulkan-ati \
    mesa \
    mesa-egl \
    mesa-utils
}

function install_misc ()
{
  box "install misc"
# Neovim need ripgrep build-base imagemagick fd unzip wget curl gcc musl-dev 
  apk add \
    neovim \ 
    ripgrep \
    build-base \
    imagemagick \
    fd \
    unzip \
    wget \
    curl \
    gcc \
    musl-dev 

  apk add \
    mc \
    ncurses \
    tmux \
    alacritty \
    go \
    btop \
    git-credential-oauth
  # oauth for GITHUB
  # git-credential-oauth configure 
  wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/AnonymousPro.zip 
  unzip AnonymousPro.zip -d /usr/local/share/fonts/
  fc-cache -fv
  chsh --shell /bin/bash vrabah
}

function install_docker() {
  box "install docker"
  apk add docker \
    docker-cli-compose \
    docker-cli-buildx
  # no sudo for docker
  usermod -aG docker vrabah 
}

function install_flatpak() {
  box "install flatpak"
  apk add flatpak
  # For Obsidian.md
  flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo 
}

update_repositories
setup
install_misc_kde
install_misc 
install_docker
install_flatpak

##################################################################
# Check GIT config : git config --global credential.helper store #
# Or you can add an alias in your ~/.gitconfig:                  #
#                                                                #
# [url "https://github.com/"]
#   insteadOf = gh://
# and execute:
# git clone gh://knoopx/repo
##################################################################


