#!/usr/bin/env bash

#/opt/vpn.sh || exit 1
pIP=$( curl 'https://api.ipify.org/?format=raw' )
if [[ $pIP == "79.120.77.117" ]]; then
    echo "Public IP: $pIP, exiting now"
    exit 1
else
    echo "Public IP: $pIP"
fi

cd /home/builder||exit 1

gpg --import $BITALSARK
gpg --fingerprint B85CCC7E84084D98FDCA5CB9619D32E653C5E767

if [[ -n "$PGPFINGER" ]]; then
    gpg --recv-keys $PGPFINGER
fi
if [[ -n "$PGPLINK" ]]; then
    curl $PGPLINK > "$AURPACKAGE"-key
    gpg --import "$AURPACKAGE"-key
fi
echo Updating pacman databases...
sudo pacman -Syy
echo Building "$AURPACKAGE"...
aur sync -A --noconfirm --noview --sign --database Bitals --root /home/builder/bitalsrepo $AURPACKAGE || exit 1
#sudo pacman -Sc --noconfirm
sudo pacleaner -n 2 -m --delete --no-confirm
#sudo kill $( cat /opt/piavpn-manual/pia_pid )