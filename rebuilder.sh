#!/usr/bin/env bash

echo Rebuilding $AURPACKAGE...
#mv /home/builder/rebuild.log /home/builder/rebuild.log.old
#for i in $( find .cache/aurutils/sync/*/.SRCINFO -exec grep -sm 1 "pkgname" {} \;|tr -d ' '|cut -d "=" -f 2 ); do
#    echo
#    echo "AURPACKAGE=" $i >> /home/builder/rebuild.log
#    echo
if [ ! -d /home/builder/.cache/aurutils/sync/"$AURPACKAGE" ]; then
    cd /home/builder/.cache/aurutils/sync/|| exit 1
    git clone https://aur.archlinux.org/"$AURPACKAGE".git || exit 1
    cd /home/builder/.cache/aurutils/sync/"$AURPACKAGE" || exit 1
fi
cd /home/builder/.cache/aurutils/sync/"$AURPACKAGE" || exit 1
makepkg -soe --nocheck --noprepare --skipchecksums --skippgpcheck --noconfirm|| makepkg -so --nocheck --noprepare --skipchecksums --skippgpcheck --noconfirm || exit 1
aur sync --makepkg-args --cleanbuild -A --noconfirm --noview --rebuild --sign --database Bitals --root /home/builder/bitalsrepo "$AURPACKAGE"|| exit 1
#done
#sudo kill $( cat /opt/piavpn-manual/pia_pid )
