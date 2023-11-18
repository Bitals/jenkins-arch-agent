#!/usr/bin/env bash

echo Updating pacman databases...
sudo pacman -Syy
echo Updating devel packages...

repover=$( pacman -Qi librem5-flash-image-git|grep Version|sed -E 's/Version         : //' )
cd /home/builder/.cache/aurutils/sync/"$AURPACKAGE"||exit
makepkg -o
gitver=$( bash -c "source PKGBUILD && pkgver" )
if [[ "$repover" != "$gitver" ]]; then
    /opt/rebuilder.sh || exit 1
else
    echo "No updates found"
    exit 0
fi