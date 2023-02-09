#! /bin/sh

#/opt/vpn.sh || exit 1
pIP=$( curl 'https://api.ipify.org/?format=raw' )
if [[ $pIP != "193.138.7.176" ]]; then
    echo "Public IP: "$pIP", exiting now"
    exit 1
else
    echo "Public IP: $pIP"
fi

mkdir /home/builder/devel
cd /home/builder/devel

gpg --import $BITALSARK
gpg --fingerprint 5D11E19794FC8007AFE3600CEB70C01D5CEABF2C

echo Updating pacman databases...
sudo pacman -Syy
echo Updating devel packages...


/opt/aur-update-devel-fork.sh --database Bitals --root /home/builder/bitalsrepo --noconfirm --noview --sign || exit 1


sudo pacman -Sc --noconfirm
#sudo kill $( cat /opt/piavpn-manual/pia_pid )