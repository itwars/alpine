#!/bin/bash

function box() {
  title="│ $* │"
  edgeTop=$(echo "$title" | sed 's/./─/g')
  edgeBot=$(echo "$title" | sed 's/./─/g')
  echo $edgeTop | sed s/─/┌/1 | sed s/─$/┐/
  echo $title
  echo $edgeBot | sed s/─/└/1 | sed s/─$/┘/
}

function install_misc ()
{
  box "install misc"
# Neovim need ripgrep build-base imagemagick fd unzip wget curl gcc musl-dev 
  sudo snap install nvim
  sudo apt install \
    ripgrep \
    fd-find \
    unzip \
    wget \
    curl \
    gcc \
    jq \
    yq

  box "install user specific tools"
  sudo snap install alacritty --classic
  sudo snap install obsidian --classic
  sudo apt install \
    mc \
    tmux \
    golang \
    btop \
    bash-completion 
  box "Install fonts"
  wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/AnonymousPro.zip 
  unzip AnonymousPro.zip -d ~/.fonts
  fc-cache -fv
  box "install z cd"
  mkdir -p /home/ivra0940/.bashrc.d/
  wget -O /home/ivra0940/.bashrc.d/z.sh https://raw.githubusercontent.com/rupa/z/master/z.sh
}

function install_docker() {
  box "install docker"
  sudo apt install \
    docker.io \
    docker-compose-v2 \
    docker-buildx \
    bridge-utils 
  # no sudo for docker
  #usermod -aG docker ivra0940 
}

function install_libvirt_qemu() {
  box "install kvm qemu libvirt"
  sudo apt install \
    libvirt-clients \
    libvirt-daemon \
    qemu-utils \
    xorriso \
    krdc
  #addgroup ivra0940 qemu
  #addgroup ivra0940 kvm
  #addgroup ivra0940 libvirt
}

install_misc 
install_docker
install_libvirt_qemu
