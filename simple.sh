#!/bin/bash



function box() {
  title="│ $* │"
  edgeTop=$(echo "$title" | sed 's/./─/g')
  edgeBot=$(echo "$title" | sed 's/./─/g')
  echo $edgeTop | sed s/─/┌/1 | sed s/─$/┐/
  echo $title
  echo $edgeBot | sed s/─/└/1 | sed s/─$/┘/
}

function setup() 
{
apk update
apk upgrade

box "Install plasma + kde"

setup-xorg-base
setup-desktop plasma
apk add plasma openrc-settingsd

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
