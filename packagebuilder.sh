#! /bin/sh

/opt/vpn.sh || exit 1

cd /home/builder
#sudo install -d /home/builder/bitalsrepo -o $USER
#repo-add /home/builder/bitalsrepo/Bitals.db.tar.gz

#sudo pacman-key -a $BITALSARK
#sudo pacman-key --finger 5D11E19794FC8007AFE3600CEB70C01D5CEABF2C
#sudo pacman-key --lsign-key 5D11E19794FC8007AFE3600CEB70C01D5CEABF2C
gpg --import $BITALSARK
gpg --fingerprint 5D11E19794FC8007AFE3600CEB70C01D5CEABF2C

#sudo pacman -Sy --noconfirm

#aur sync -A --noconfirm --noview --repo Bitals --root /home/builder/bitalsrepo paru
echo Building $AURPACKAGE
aur sync -A --noconfirm --noview --sign --database Bitals --root /home/builder/bitalsrepo $AURPACKAGE || exit 1 #sudo kill $( cat /opt/piavpn-manual/pia_pid ) #&& rm -rf /home/builder/.cache/
sudo pacman -Sc --noconfirm
sudo kill $( cat /opt/piavpn-manual/pia_pid )