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
box "Install plasma + kde"

setup-xorg-base
setup-desktop plasma
apk add plasma openrc-settingsd
apk add xf86-video-amdgpu
apk add frameworkintegration5 # allowed you to install new themes !!!

rc-update add dbus
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

function install_misc_kde(){
  apk add \
    vulkan-tools \
    opencl \
    wayland \
    wayland-utils \
    mesa-vulkan-ati \
    mesa \
    mesa-egl \
    mesa-utils
}

function install_misc () {
  apk add \
    mc \
    neovim \ # Neovim need ripgrep build-base imagemagick fd unzip wget curl gcc musl-dev 
    ripgrep \
    build-base \
    imagemagick \
    fd \
    unzip \
    wget \
    curl \
    gcc \
    musl-dev \
    ncurses \
    tmux \
    alacritty \
    go \
    btop \
    git-credential-oauth
  git-credential-oauth configure # oauth for GITHUB
  wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/AnonymousPro.zip 
  unzip AnonymousPro.zip -d ~/.fonts/
  fc-cache -fv
  chsh --shell /bin/bash vrabah
}

function install_docker() {
  apk add docker \
    docker-cli-compose \
    docker-cli-buildx
  # No sudo for docker
  usermod -aG docker vrabah 
}

function install_flatpak() {
  apk add flatpak
  flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo # For Obsidian.md
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


