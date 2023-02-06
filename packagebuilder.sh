#! /bin/sh

#/opt/vpn.sh || exit 1
pIP=$( curl 'https://api.ipify.org?format=raw' )
if [[ $pIP != "193.138.7.176" ]]; then
    echo "Public IP: "$pIP", exiting now"
    exit 1
else
    echo "Public IP: $pIP"
fi

cd /home/builder

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
echo Building "$AURPACKAGE"...
aur sync -A --noconfirm --noview --sign --database Bitals --root /home/builder/bitalsrepo $AURPACKAGE || exit 1 || rm -rf /home/builder/.cache/aurutils/sync/$AURPACKAGE
sudo pacman -Sc --noconfirm
#sudo kill $( cat /opt/piavpn-manual/pia_pid )