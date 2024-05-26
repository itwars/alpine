#!/bin/bash

doas apk add hyprland xdg-desktop-portal-hyprland --repository=https://dl-cdn.alpinelinux.org/alpine/edge/testing 
              
doas apk add  waybar \
              rofi-wayland \
              kitty \
              kitty-kitten \
              brightnessctl \
              mako \
              grim \
              wl-clipboard \
              slurp \
              librsvg \
              swaybg \
              mate-polkit \
              seatd \
              consolekit2 \
              waybar 
