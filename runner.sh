#!/usr/bin/env bash

#/opt/vpn.sh || exit 1
pIP=$( curl 'https://bitals.xyz/ipify/?format=raw' )
if [[ $pIP == "79.120.77.117" ]]; then
    echo "Public IP: $pIP, exiting now"
    exit 1
else
    echo "Public IP: $pIP"
fi
pIP=""

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

if [[ -z $Action ]] || [[ $Action == "default" ]]; then
    /opt/packagebuilder.sh
elif [[ $Action == "custom" ]]; then
    /opt/custombuilder.sh
elif [[ $Action == "force-rebuild" ]]; then
    /opt/rebuilder.sh
elif [[ $Action == "update-devel" ]]; then
    /opt/update-devel.sh
fi


#sudo pacman -Sc --noconfirm
##When aurutils will get a sane version number again
#sudo pacleaner -n 2 -m --delete --no-confirm