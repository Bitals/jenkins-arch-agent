#!/usr/bin/env bash

echo Updating pacman databases...
sudo pacman -Syy
echo Updating devel packages...

repover=$( pacman -Si "$AURPACKAGE"|grep Version|sed -E 's/Version         : //' )
cd /home/builder/.cache/aurutils/sync/"$AURPACKAGE"|| /opt/rebuilder.sh
makepkg -o
gitver=$( bash -c "source PKGBUILD && echo ${pkgver//%}" )
echo Repo: $repover
echo Source: $gitver
if [[ "$repover" != "$gitver" ]]; then
    /opt/rebuilder.sh || exit 1
else
    echo "No updates found"
    exit 0
fi