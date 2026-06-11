#!/bin/bash

case $1 in
lock)
  swaylock -f --image "/home/filipe/Imagens/Wallpaper/world-map-black-and-3840x2160-16671.png"
  ;;
logout)
  swaymsg exit
  ;;
reboot)
  systemctl reboot
  ;;
shutdown)
  systemctl poweroff
  ;;
esac
