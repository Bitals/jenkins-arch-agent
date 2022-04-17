#! /bin/sh

echo "Installing OpenVPN"
sudo pacman -Sy --noconfirm openvpn
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