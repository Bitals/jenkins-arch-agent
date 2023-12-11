#!/usr/bin/env bash

echo Updating pacman databases...
sudo pacman -Syy
echo Rebuilding $AURPACKAGE...
#mv /home/builder/rebuild.log /home/builder/rebuild.log.old
#for i in $( find .cache/aurutils/sync/*/.SRCINFO -exec grep -sm 1 "pkgname" {} \;|tr -d ' '|cut -d "=" -f 2 ); do
#    echo
#    echo "AURPACKAGE=" $i >> /home/builder/rebuild.log
#    echo
cd /home/builder/.cache/aurutils/sync/"$AURPACKAGE" || exit 1
makepkg -soe --nocheck --noprepare --skipchecksums --skippgpcheck --noconfirm|| exit 1
aur sync -A --noconfirm --noview --rebuild --sign --database Bitals --root /home/builder/bitalsrepo "$AURPACKAGE"|| exit 1
#done
#sudo kill $( cat /opt/piavpn-manual/pia_pid )