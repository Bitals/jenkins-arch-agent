#!/usr/bin/env bash

echo Updating pacman databases...
sudo pacman -Syy
echo Rebuilding $AURPACKAGE...
#mv /home/builder/rebuild.log /home/builder/rebuild.log.old
#for i in $( find .cache/aurutils/sync/*/.SRCINFO -exec grep -sm 1 "pkgname" {} \;|tr -d ' '|cut -d "=" -f 2 ); do
#    echo
#    echo "AURPACKAGE=" $i >> /home/builder/rebuild.log
#    echo
aur sync -A --noconfirm --noview --rebuild --sign --database Bitals --root /home/builder/bitalsrepo "$AURPACKAGE"|| exit 1
#sudo pacman -Sc --noconfirm
sudo pacleaner -n 2 -m --delete --no-confirm
#done
#sudo kill $( cat /opt/piavpn-manual/pia_pid )