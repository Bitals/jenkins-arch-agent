#!/usr/bin/env bash

#/opt/vpn.sh || exit 1
pIP=$( curl 'https://api.ipify.org/?format=raw' )
if [[ $pIP != "185.204.1.226" ]]; then
    echo "Public IP: $pIP, exiting now"
    exit 1
else
    echo "Public IP: $pIP"
fi

mkdir /home/builder/devel
cd /home/builder||exit 1

gpg --import $BITALSARK
gpg --fingerprint 5D11E19794FC8007AFE3600CEB70C01D5CEABF2C

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


sudo pacman -Sc --noconfirm
#sudo kill $( cat /opt/piavpn-manual/pia_pid )