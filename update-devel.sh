#!/usr/bin/env bash

echo Updating pacman databases...
sudo pacman -Syy
echo Updating devel packages...

repover=$( pacman -Si "$AURPACKAGE"|grep Version|sed -E 's/Version         : //' )
cd /home/builder/.cache/aurutils/sync/"$AURPACKAGE"|| echo "No local source found, rebuilding" && /opt/rebuilder.sh
makepkg -o
gitver=$( grep pkgver= PKGBUILD|cut -d "=" -f 2 )
echo Repo: $repover
echo Source: $gitver
if [[ "$repover" != "$gitver" ]]; then
    /opt/rebuilder.sh || exit 1
else
    echo "No updates found"
    exit 0
fi