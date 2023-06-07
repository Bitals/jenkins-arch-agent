#!/usr/bin/env bash

echo Updating pacman databases...
sudo pacman -Syy
echo Building "$AURPACKAGE"...
aur sync -A --noconfirm --noview --sign --database Bitals --root /home/builder/bitalsrepo $AURPACKAGE || exit 1
#sudo pacman -Sc --noconfirm
sudo pacleaner -n 2 -m --delete --no-confirm
#sudo kill $( cat /opt/piavpn-manual/pia_pid )