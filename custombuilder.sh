#!/usr/bin/env bash

echo Updating pacman databases...
sudo pacman -Syy
echo Building "$OWNPACKAGE"...

cd /home/builder/workspace/AUR/"$OWNPACKAGE"
#makepkg --printsrcinfo > .SRCINFO
#aur graph .SRCINFO | tsort | tac > queue
#repo-remove /home/builder/bitalsrepo/Bitals.db.tar.gz $OWNPACKAGE
# rm -rf /home/builder/bitalsrepo/$OWNPACKAGE.pkg.tar.zst
# rm -rf    $OWNPACKAGE.pkg.tar.zst.sig
# rm -rf /home/builder/
# rm -rf /home/builder/
aur build --database Bitals --root /home/builder/bitalsrepo $OWNPACKAGE|| exit 1
sudo pacman -Sy --noconfirm $OWNPACKAGE || exit 1
#sudo kill $( cat /opt/piavpn-manual/pia_pid )