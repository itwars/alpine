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

function install_xwindow ()
{
  box "install xwindow stuffs"
  apk add \
   xf86-video-amdgpu \
   xf86-input-libinput \
   dbus \
   dbus-x11 \
   elogind \
   polkit-elogind

  rc-update add dbus
  rc-service dbus start
  rc-update add elogind
  rc-service elogind start
  rc-update add polkit

  setup-xorg-base
}


function install_kde ()
{
  box "install kde"
  apk add \
    plasma \
    networkmanager-dnsmasq \
    kde-applications-admin \
    kde-applications-base \
    kde-applications-network
  setup-devd udev
  rc-update add sddm
  rc-service sddm start
}

function start_with_plasma()
{
cat << EOF> /home/vrabah/.xinitrc 
XDG_SESSION_TYPE=wayland dbus-run-session startplasma-wayland
EOF
}

function install_misc() {
   apk add \
    mc \
    neovim \
    gcc \
    tmux \
    mesa-vulkan-ati # UTILE ?
}

update_repositories
install_xwindow
install_kde
start_with_plasma
install_misc
