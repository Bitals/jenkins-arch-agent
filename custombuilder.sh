#!/usr/bin/env bash

echo Building "$OWNPACKAGE"...

cd /home/builder/workspace/AUR/"$OWNPACKAGE" || exit 1
#makepkg --printsrcinfo > .SRCINFO
#aur graph .SRCINFO | tsort | tac > queue
#repo-remove /home/builder/bitalsrepo/Bitals.db.tar.gz $OWNPACKAGE
# rm -rf /home/builder/bitalsrepo/$OWNPACKAGE.pkg.tar.zst
# rm -rf    $OWNPACKAGE.pkg.tar.zst.sig
# rm -rf /home/builder/
# rm -rf /home/builder/
deps=""
for i in $( grep "depends" .SRCINFO|grep -v optdepends|cut -d "=" -f 2|cut -d ":" -f 1 ); do
    deps+="$i "
done
sudo pacman -S --noconfirm $deps
aur build -f --database Bitals --root /home/builder/bitalsrepo $OWNPACKAGE|| exit 1
sudo pacman -Sy --noconfirm $OWNPACKAGE || exit 1
#sudo kill $( cat /opt/piavpn-manual/pia_pid )
