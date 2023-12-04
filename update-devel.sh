#!/usr/bin/env bash

echo Updating pacman databases...
sudo pacman -Syy
echo Updating devel packages...

repover=$( pacman -Si $AURPACKAGE|grep Version|sed -E 's/Version         : //'|cut -d "-" -f 1 )
if [ ! -d /home/builder/.cache/aurutils/sync/"$AURPACKAGE" ]; then
    cd /home/builder/.cache/aurutils/sync/|| exit 1
    git clone https://aur.archlinux.org/"$AURPACKAGE".git || exit 1
fi
cd /home/builder/.cache/aurutils/sync/"$AURPACKAGE" || exit 1
makepkg -do
gitver=$( grep pkgver= PKGBUILD|cut -d "=" -f 2 )
echo Repo: $repover
echo Source: $gitver
if [[ -n "$repover" && "$repover" != "$gitver" ]]; then
    /opt/rebuilder.sh || exit 1
else
    echo "No updates found"
    exit 0
fi