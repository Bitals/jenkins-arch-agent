#! /bin/sh

/opt/vpn.sh

cd $OWNPACKAGE
makepkg --printsrcinfo > .SRCINFO
aur graph .SRCINFO | tsort | tac > queue
aur build --database Bitals --root /home/builder/bitalsrepo -a queue
#sudo pacman -Sy --noconfirm brave
#sudo pacman -Sc --noconfirm