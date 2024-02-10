#!/bin/bash

apk update
apk upgrade


setup-xorg-base
setup-desktop plasma

rc-update add dbus
rc-update add sddm
rc-update add fuse
rc-update add elogind

apk add networkmanager networkmanager-wifi

addgroup vrabah plugdev                                  
rc-update add networkmanager                         
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
wifi.backend=wpa_supplicant                          
EOF
