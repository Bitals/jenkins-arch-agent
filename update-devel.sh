#!/usr/bin/env bash

#/opt/vpn.sh || exit 1
pIP=$( curl 'https://api.ipify.org/?format=raw' )
if [[ $pIP != "193.138.7.176" ]]; then
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


if [[ $(aur vercmp-devel -database Bitals --root /home/builder/bitalsrepo | grep $AURPACKAGE | tee updates) ]]; then
    printf "\n$(column -t updates)\n\n$(wc -l updates) found.  "
    cut -d\  -f1 updates > vcs.txt
    xargs -a vcs.txt aur sync --no-ver-argv --noconfirm --noview --sign -database Bitals --root /home/builder/bitalsrepo || exit 1
else
    msg2 "No updates found"
fi
#/opt/aur-update-devel-fork.sh --database Bitals --root /home/builder/bitalsrepo || exit 1


sudo pacman -Sc --noconfirm
#sudo kill $( cat /opt/piavpn-manual/pia_pid )