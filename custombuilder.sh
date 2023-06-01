#!/usr/bin/env bash

#/opt/vpn.sh || exit 1
pIP=$( curl 'https://api.ipify.org/?format=raw' )
if [[ $pIP != "185.204.1.226" ]]; then
    echo "Public IP: $pIP, exiting now"
    exit 1
else
    echo "Public IP: $pIP"
fi

gpg --import $BITALSARK
gpg --fingerprint B85CCC7E84084D98FDCA5CB9619D32E653C5E767


if [[ -n "$PGPFINGER" ]]; then
    gpg --recv-keys $PGPFINGER
fi
if [[ -n "$PGPLINK" ]]; then
    curl $PGPLINK > "$OWNPACKAGE"-key
    gpg --import "$OWNPACKAGE"-key
fi
echo Updating pacman databases...
sudo pacman -Syy
echo Building "$OWNPACKAGE"...

makepkg --printsrcinfo > .SRCINFO
#aur graph .SRCINFO | tsort | tac > queue
#repo-remove /home/builder/bitalsrepo/Bitals.db.tar.gz $OWNPACKAGE
# rm -rf /home/builder/bitalsrepo/$OWNPACKAGE.pkg.tar.zst
# rm -rf /home/builder/bitalsrepo/$OWNPACKAGE.pkg.tar.zst.sig
# rm -rf /home/builder/
# rm -rf /home/builder/
aur build --database Bitals --root /home/builder/bitalsrepo $OWNPACKAGE|| exit 1
sudo pacman -Sy --noconfirm $OWNPACKAGE || exit 1
#sudo pacman -Sc --noconfirm
sudo pacleaner -n 2 -m --delete --no-confirm
#sudo kill $( cat /opt/piavpn-manual/pia_pid )