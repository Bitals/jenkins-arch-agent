#!/usr/bin/env bash

echo Updating pacman databases...
sudo pacman -Syy
echo Building "$AURPACKAGE"...
aur sync -A --noconfirm --noview --sign --database Bitals --root /home/builder/bitalsrepo $AURPACKAGE || exit 1
#sudo kill $( cat /opt/piavpn-manual/pia_pid )