#! /bin/sh

/opt/vpn.sh

cd $OWNPACKAGE
makepkg --printsrcinfo > .SRCINFO
#aur graph .SRCINFO | tsort | tac > queue
aur build --database Bitals --root /home/builder/bitalsrepo -a $OWNPACKAGE
#sudo pacman -Sy --noconfirm $OWNPACKAGE
#sudo pacman -Sc --noconfirm