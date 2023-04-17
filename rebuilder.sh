#!/usr/bin/env bash

#/opt/vpn.sh || exit 1
pIP=$( curl 'https://api.ipify.org/?format=raw' )
if [[ $pIP != "185.204.1.226" ]]; then
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
echo Rebuilding everything...
mv /home/builder/rebuild.log /home/builder/rebuild.log.old
for i in $( find .cache/aurutils/sync/*/.SRCINFO -exec grep -sm 1 "pkgname" {} \;|tr -d ' '|cut -d "=" -f 2 ); do
    echo
    echo "AURPACKAGE=" $i >> /home/builder/rebuild.log
    echo
	aur sync -A --noconfirm --noview --rebuild --sign --database Bitals --root /home/builder/bitalsrepo $i >> /home/builder/rebuild.log
	sudo pacman -Sc --noconfirm
done