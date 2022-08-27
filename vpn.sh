#! /bin/sh

echo "Installing OpenVPN"
sudo pacman -Sy --noconfirm openvpn|| exit 1
echo "Creating TUN device /dev/net/tun"
sudo mkdir -p /dev/net
sudo mknod /dev/net/tun c 10 200
sudo chmod 0666 /dev/net/tun
echo "Connecting to PIA OpenVPN"
cd /home/builder/manual-connections
succ=false
i=0
while [[ $succ != true ]] && [[ $i -le 5 ]]; do
    sleep $((5*$i))s
    sudo VPN_PROTOCOL=openvpn_udp_standard DISABLE_IPV6="yes" AUTOCONNECT=true PIA_DNS=false PIA_PF=false PIA_USER=$PIA_USER PIA_PASS=$PIA_PASS ./run_setup.sh
    if [[ -z $( cat /opt/piavpn-manual/pia_pid ) ]]; then
        echo "VPN connectin failed, will try again in 5s"
        succ=false
        ((i++))
        sudo killall openvpn
    else
        succ=true
    fi
done
if [[ $succ == false  ]]; then
    exit 1
fi
echo "Adding route to local network"
sudo ip route add "10.10.22.0/24" via "172.18.0.1" dev "eth0"
sudo ip route add "10.10.43.0/24" via "172.18.0.1" dev "eth0"
echo "Public IP: $( curl https://2ip.ru )"