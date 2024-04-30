#!/usr/bin/env bash

echo Updating devel packages...

#TODO: Handle $AURPACKAGE arrays

repover=$( pacman -Si "$AURPACKAGE"|grep Version|sed -E 's/Version         : //' )
repopkgver=$(echo "$repover"|rev|cut -d '-' --complement -f 1|rev)
repopkgrel=$(echo "$repover"|rev|cut -d '-' -f 1|rev)
if [ ! -d /home/builder/.cache/aurutils/sync/"$AURPACKAGE" ]; then
    cd /home/builder/.cache/aurutils/sync/|| exit 1
    git clone https://aur.archlinux.org/"$AURPACKAGE".git || exit 1
    cd /home/builder/.cache/aurutils/sync/"$AURPACKAGE" || exit 1
    makepkg -do --nocheck --noprepare --noconfirm|| exit 1
fi

src=$(ls /home/builder/.cache/aurutils/sync/"$AURPACKAGE"/src)
if [ -z "$src" ]; then
    cd /home/builder/.cache/aurutils/sync/"$AURPACKAGE" || exit 1
    git reset --hard
    git pull || exit 1
    makepkg -do --nocheck --noprepare --noconfirm|| exit 1
fi
cd /home/builder/.cache/aurutils/sync/"$AURPACKAGE" || exit 1
makepkg -do || exit 1
gitpkgver=$( grep pkgver= PKGBUILD|cut -d "=" -f 2 )
gitpkgrel=$( grep pkgrel= PKGBUILD|cut -d "=" -f 2 )
gitver="$gitpkgver"-"$gitpkgrel"
echo Repover: "$repover"
echo Sourcever: "$gitver"
# Separate IFs instead of && to ~try to~ make it ~a bit~ more readable
# Basically here we check if there has been any change in complete version at all
if [[ -n "$gitver" && "$repover" != "$gitver" ]]; then
    echo "Versions differ"
    # If yes then we check if upstream *pkgver* specifically has changed, ignoring *pkgrel*
    # TODO:support epoch (seems to be rare for development packages)
    # If yes we rebuild
    echo Repopkgver: "$repopkgver"
    echo Sourcepkgver: "$gitpkgver"
    if [[ "$gitpkgver" != "$repopkgver" ]]; then
        echo "Got an upstream update"
        /opt/rebuilder.sh || exit 1
    else
        # If not then we check if AUR' pkgrel is newer then repo',
        # e.g. do not rebuild if a dependency bump +0.1 happened before, but upstream didn't change
        echo Repopkgrel: "$repopkgrel"
        echo Sourcepkgrel: "$gitpkgrel"
        if (( $(echo "$gitpkgrel" \> "$repopkgrel"|bc -l) )); then
            echo "Got an AUR update"
            /opt/rebuilder.sh "$AURPACKAGE" || exit 1
        else
            echo "Repo pkrel is newer, skip building"
            exit 0
        fi
    fi
else
    echo "No updates found"
    exit 0
fi
