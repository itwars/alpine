#!/bin/sh

# non-interactive kde installer for alpine 

# apk add curl && curl -L https://cutt.ly/alpine_kde | sh

echo "I will make Alpine Linux a Desktop Linux.. ."

## Desktop user

apk add sudo
export USER='user'
adduser -D $USER && echo "$USER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$USER && chmod 0440 /etc/sudoers.d/$USER
echo "➜ Desktop user created"

## 

echo "‣ Add login manager"
## Set here your preferred X driver
apk add xf86-video-modesetting
setup-xorg-base

echo "‣ Add main and community repositories"
cat > /etc/apk/repositories << EOF; $(echo)
http://dl-cdn.alpinelinux.org/alpine/v$(cat /etc/alpine-release | cut -d'.' -f1,2)/main
http://dl-cdn.alpinelinux.org/alpine/v$(cat /etc/alpine-release | cut -d'.' -f1,2)/community
EOF

apk update

echo "★ Install locales"
apk add musl-locales lang

cat > /etc/profile.d/99-fr.sh << EOF;
LANG=fr_FR.UTF-8
LC_CTYPE=fr_FR.UTF-8
LC_NUMERIC=fr_FR.UTF-8
LC_TIME=fr_FR.UTF-8
LC_COLLATE=fr_FR.UTF-8
LC_MONETARY=fr_FR.UTF-8
LC_MESSAGES=fr_FR.UTF-8
LC_ALL=
EOF

echo "★ Install AMD GPU"
apk add xf86-video-amdgpu
apk add xf86-input-libinput

echo "★ Add Desktop Environment"
apk add plasma-desktop kde-applications-network kde-applications-base
apk add polkit consolekit2 breeze breeze-icons systemsettings

cat > /home/$USER/.xinitrc << EOF;
XDG_SESSION_TYPE=wayland dbus-run-session startplasma-wayland
EOF

# Add NetworkManager
apk add plasma-nm
rc-service networkmanager start
rc-update add networkmanager


# Add fuse
apk add fuse-openrc gvfs-fuse gvfs-smb
rc-service fuse start
rc-update add fuse

# NOTE: `sddm` do not work
apk add lightdm lightdm-gtk-greeter dbus-x11 
# rc-service lightdm start
rc-update add lightdm

apk add alsa-utils alsa-lib alsaconf
addgroup $USER audio
addgroup root audio



apk add pulseaudio pulseaudio-alsa alsa-plugins-pulse

rc-service alsa start
rc-update add alsa


echo "★ Add software"
# apk add firefox-esr
#apk add chromium
apk add htop neofetch

echo "★★★ Congrats! ★★★ run: passwd user, to set your user password and then run: reboot"


## Some more stuff you could need

rc-service wpa_supplicant start
/etc/init.d/networking restart
sudo rc-update add wpa_supplicant boot
sudo apk add acpi
sudo apk add cpufreqd
sudo rc-update add cpufreqd
sudo apk add xbacklight xrand

## FIXME

#- brightness keys not working
#- networkmanager 
#- pulseaudio
#  no shutdown from GUI
#- no auth mount usbke
