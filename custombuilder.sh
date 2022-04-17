#! /bin/sh

/opt/vpn.sh

gpg --import $BITALSARK
gpg --fingerprint 5D11E19794FC8007AFE3600CEB70C01D5CEABF2C

cd $OWNPACKAGE
makepkg --printsrcinfo > .SRCINFO
#aur graph .SRCINFO | tsort | tac > queue
aur build --database Bitals --root /home/builder/bitalsrepo $OWNPACKAGE|| exit 1
sudo pacman -Sy --noconfirm $OWNPACKAGE
sudo pacman -Sc --noconfirm