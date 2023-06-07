#!/usr/bin/env bash

echo Updating pacman databases...
sudo pacman -Syy
echo Updating devel packages...


if [[ $(aur vercmp-devel --database Bitals --root /home/builder/bitalsrepo | tee updates) ]]; then
    printf "\n$(column -t updates)\n\n$(wc -l updates) found.  "
    grep $AURPACKAGE updates| cut -d\  -f1  > vcs.txt
    if [[ -n $( cat vcs.txt ) ]]; then
        xargs -a vcs.txt aur sync --no-ver-argv --noconfirm --noview --sign --database Bitals --root /home/builder/bitalsrepo || exit 1
    else
        echo "No updates found"
        exit 0
    fi
else
    echo "No updates found"
    exit 0
fi
#/opt/aur-update-devel-fork.sh --database Bitals --root /home/builder/bitalsrepo || exit 1


#sudo pacman -Sc --noconfirm
sudo pacleaner -n 2 -m --delete --no-confirm
#sudo kill $( cat /opt/piavpn-manual/pia_pid )