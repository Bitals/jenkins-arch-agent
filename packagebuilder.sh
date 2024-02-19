#!/usr/bin/env bash

echo Building "$AURPACKAGE"...
if [ $( echo "$AURPACKAGE"|rev|cut -d "-" -f 1|rev ) == "git" ]; then
    /opt/rebuilder.sh || exit 1
else
  aur sync -A --noconfirm --noview --sign --database Bitals --root /home/builder/bitalsrepo "$AURPACKAGE" || exit 1
  echo $(grep -m 1 epoch= /home/builder/.cache/aurutils/sync/"$AURPACKAGE"/PKGBUILD|cut -d = -f 2):$(grep -m 1 pkgver= /home/builder/.cache/aurutils/sync/"$AURPACKAGE"/PKGBUILD|cut -d = -f 2)-$(grep -m 1 pkgrel= /home/builder/.cache/aurutils/sync/"$AURPACKAGE"/PKGBUILD|cut -d = -f 2) > jenkins-ver-info
fi
  #sudo kill $( cat /opt/piavpn-manual/pia_pid )
