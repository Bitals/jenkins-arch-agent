#! /bin/sh

/opt/vpn.sh || exit 1

gpg --import $BITALSARK
gpg --fingerprint 5D11E19794FC8007AFE3600CEB70C01D5CEABF2C

if [[ -z "$PGPFINGER" ]]; then
    break
else
    gpg --recv-keys $PGPFINGER
fi
if [[ -z "$PGPLINK" ]]; then
    break
else
    curl $PGPLINK > "$AURPACKAGE"-key
    gpg --import "$AURPACKAGE"-key
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
sudo pacman -Sc --noconfirm
sudo kill $( cat /opt/piavpn-manual/pia_pid )