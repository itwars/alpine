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
apk add --quiet openrc-settingsd musl-locales dbus polkit
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
  sleep 30
fi

box "Install plasma + kde"
setup-xorg-base

box "setup plasma"
setup-desktop plasma
apk add --quiet plasma

box "install kde base app"
apk add --quiet kde-applications-base

box "setup wayland"
apk add --quiet xf86-video-amdgpu wayland-utils wl-clipboard
# allowed you to install new themes !!!
apk add --quiet frameworkintegration5 

rc-update add sddm
rc-update add fuse
rc-update add elogind

box "Fix sddm enter key issue"
echo "[General]" >> /etc/sddm.conf 
echo "InputMethod=" >> /etc/sddm.conf 

box "Install networkmanager"
apk add --quiet networkmanager networkmanager-wifi iwd
sed -i 's/^#EnableNetworkConfiguration=True/EnableNetworkConfiguration=True/' /etc/iwd/main.conf
sed -i 's/^#NameResolvingService=resolvconf/NameResolvingService=resolvconf/' /etc/iwd/main.conf

addgroup vrabah plugdev                                 
rc-update add networkmanager
rc-update add iwd 
rc-update del networking
rc-update del wpa_supplicant


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

box "Install bluetooth"
setup-devd udev
apk add --quiet bluez pipewire-spa-bluez pipewire-spa-tools pipewire-spa-vulkan qt5-qtconnectivity
modprobe btusb 
addgroup vrabah lp
rc-service bluetooth start 
rc-update add bluetooth
}

setup_kernel_silent() {
  if grep -q \#rc_parallel=\"NO\" /etc/rc.conf; then
    # uses "@" as a delimiter; the '-i' flag edits the file in-place
    sed -i 's@#rc_parallel="NO"@rc_parallel="YES"@g' /etc/rc.conf
  else
    box "WARNING: unable to find the string '#rc_parallel=\"NO\"' in /etc/rc.conf"
  fi
  # openrc sysinit
  if grep -q "openrc sysinit --quiet" /etc/inittab; then
      box "WARNING: the file '/etc/inittab' alredy contains the string 'openrc sysinit --quiet', as such the script will not commit any changes and it adivised to check the '/etc/inittab' integrity manually."
  else
      sed -i 's@openrc sysinit@openrc sysinit --quiet@g' /etc/inittab
  fi
  
  # openrc boot
  if grep -q "openrc boot --quiet" /etc/inittab; then
      box "WARNING: the file '/etc/inittab' alredy contains the string 'openrc boot --quiet', as such the script will not commit any changes and it adivised to check the '/etc/inittab' integrity manually."
  else
      sed -i 's@openrc boot@openrc boot --quiet @g' /etc/inittab
  fi
  
  # openrc default
  if grep -q "openrc default --quiet" /etc/inittab; then
      box "WARNING: the file '/etc/inittab' alredy contains the string 'openrc default --quiet', as such the script will not commit any changes and it adivised to check the '/etc/inittab' integrity manually."
  else
      sed -i 's@openrc default@openrc default --quiet@g' /etc/inittab
  fi
  
  # openrc shutdown
  if grep -q "openrc shutdown --quiet" /etc/inittab; then
      box "WARNING: the file '/etc/inittab' alredy contains the string 'openrc shutdown --quiet', as such the script will not commit any changes and it adivised to check the '/etc/inittab' integrity manually."
  else
      sed -i 's@openrc shutdown@openrc shutdown --quiet@g' /etc/inittab
  fi
}

function install_misc_kde() {
  box "install misc KDE"
  apk add --quiet \
    vulkan-tools \
    opencl \
    wayland \
    mesa-vulkan-ati \
    mesa-vulkan-layers \
    mesa-vulkan-swrast \
    mesa \
    mesa-egl \
    mesa-utils
}

function install_misc ()
{
  box "install misc"
# Neovim need ripgrep build-base imagemagick fd unzip wget curl gcc musl-dev 
  apk add --quiet \
    neovim \
    ripgrep \
    build-base \
    imagemagick \
    fd \
    unzip \
    wget \
    curl \
    gcc \
    musl-dev \
    jq \
    yq

box "install user specific tools"

  apk add --quiet \
    mc \
    ncurses \
    tmux \
    alacritty \
    go \
    btop \
    git-credential-oauth \
    bash-completion \
    isoimagewriter
  box "Install fonts"
  wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/AnonymousPro.zip 
  unzip AnonymousPro.zip -d /usr/local/share/fonts/
  fc-cache -fv
  box "install z cd"
  mkdir -p /home/vrabah/.bashrc.d/
  wget -O /home/vrabah/.bashrc.d/z.sh https://raw.githubusercontent.com/rupa/z/master/z.sh
  box "change shell to bash"
  chsh --shell /bin/bash vrabah
cat << EOF > /home/vrabah/.profile
source .bashrc
source /etc/bash/bash_completion.sh
EOF
}

function install_docker() {
  box "install docker"
  apk add --quiet docker \
    docker-cli-compose \
    docker-cli-buildx \
    bridge-utils \
    bridge
  # no sudo for docker
  usermod -aG docker vrabah 
  rc-update add docker
  rc-service docker start
}

function install_libvirt_qemu() {
  box "install kvm qemu libvirt"
  apk add --quiet libvirt-client \
    libvirt-daemon \
    qemu \
    qemu-system-x86_64 \
    qemu-img \
    qemu-modules \
    xorriso \
    krdc
  rc-update add libvirtd
  rc-update add libvirt-guests
  addgroup vrabah qemu
  addgroup vrabah kvm
  addgroup vrabah libvirt
  box "change socket group for libvirtd"
  sed -i 's/^#unix_sock_group = "libvirt"/unix_sock_group = "libvirt"/' /etc/libvirt/libvirtd.conf 
  sed -i 's/^#unix_sock_rw_perms = "0770"/unix_sock_rw_perms = "0770"/' /etc/libvirt/libvirtd.conf
}

function install_flatpak() {
  apk add fuse
  box "install flatpak"
  apk add --quiet flatpak
  # For Obsidian.md
  flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo 
}

update_repositories
setup
setup_kernel_silent
install_misc_kde
install_misc 
install_docker
install_libvirt_qemu
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

# Name                               Application ID                                 Version                Branch                Installation
 #Jarosław Foksa                     com.boxy_svg.BoxySVG                           4.27.3                 stable                system
 #Popsicle                           com.system76.Popsicle                          1.3.0                  stable                system
 #Peter Squicciarini                 com.vscodium.codium                            1.87.2.24072           stable                system
 #WPS Office                         com.wps.Office                                 11.1.0.11698           stable                system
 #Obsidian                           md.obsidian.Obsidian                           1.5.11                 stable                system
 #Freedesktop Platform               org.freedesktop.Platform                       21.08.22               21.08                 system
 #Freedesktop Platform               org.freedesktop.Platform                       22.08.22               22.08                 system
 #Freedesktop Platform               org.freedesktop.Platform                       23.08.14               23.08                 system
 #Mesa                               org.freedesktop.Platform.GL.default            21.3.9                 21.08                 system
 #Mesa                               org.freedesktop.Platform.GL.default            24.0.3                 22.08                 system
 #Mesa (Extra)                       org.freedesktop.Platform.GL.default            24.0.3                 22.08-extra           system
 #Mesa                               org.freedesktop.Platform.GL.default            24.0.3                 23.08                 system
 #Mesa (Extra)                       org.freedesktop.Platform.GL.default            24.0.3                 23.08-extra           system
 #Intel                              org.freedesktop.Platform.VAAPI.Intel                                  21.08                 system
 #Intel                              org.freedesktop.Platform.VAAPI.Intel                                  22.08                 system
 #Intel                              org.freedesktop.Platform.VAAPI.Intel                                  23.08                 system
 #openh264                           org.freedesktop.Platform.openh264              2.1.0                  2.0                   system
 #openh264                           org.freedesktop.Platform.openh264              2.1.0                  2.2.0                 system
 #Freedesktop SDK                    org.freedesktop.Sdk                            23.08.14               23.08                 system
 #Breeze GTK theme                   org.gtk.Gtk3theme.Breeze                       5.27.8                 3.22                  system
 #KDE Application Platform           org.kde.Platform                                                      5.15-23.08            system
 #DB Browser for SQLite              org.sqlitebrowser.sqlitebrowser                3.12.2                 stable                system
