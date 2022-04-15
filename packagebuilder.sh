#! /bin/sh

echo "Creating TUN device /dev/net/tun"
sudo mkdir -p /dev/net
sudo mknod /dev/net/tun c 10 200
sudo chmod 0666 /dev/net/tun
echo "Connecting to PIA OpenVPN"
cd /home/builder/manual-connections
sudo VPN_PROTOCOL=openvpn_udp_standard DISABLE_IPV6="yes" AUTOCONNECT=true PIA_DNS=true PIA_PF=false PIA_USER=$PIA_USER PIA_PASS=$PIA_PASS ./run_setup.sh || exit 1
echo "Adding route to local network"
sudo ip route add "192.168.88.0/24" via "172.18.0.1" dev "eth0"
echo "Public IP: $( curl https://2ip.ru )"
cd /home/builder
#sudo install -d /home/builder/bitalsrepo -o $USER
#repo-add /home/builder/bitalsrepo/Bitals.db.tar.gz

#sudo pacman-key -a $BITALSARK
#sudo pacman-key --finger 5D11E19794FC8007AFE3600CEB70C01D5CEABF2C
#sudo pacman-key --lsign-key 5D11E19794FC8007AFE3600CEB70C01D5CEABF2C
gpg --import $BITALSARK
gpg --fingerprint 5D11E19794FC8007AFE3600CEB70C01D5CEABF2C

sudo pacman -Sy --noconfirm

#aur sync -A --noconfirm --noview --repo Bitals --root /home/builder/bitalsrepo paru
echo Building $AURPACKAGE
aur sync -A --noconfirm --noview --sign --database Bitals --root /home/builder/bitalsrepo $AURPACKAGE || exit 1 #sudo kill $( cat /opt/piavpn-manual/pia_pid ) #&& rm -rf /home/builder/.cache/
sudo kill $( cat /opt/piavpn-manual/pia_pid )