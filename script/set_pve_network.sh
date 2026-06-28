#!/bin/bash

## nic0 adalah interface PVE host router yang menghadap ke ISP LAN ##
## vmbr0 adalah interface PVE host router yang menghadap ke private subnet container ##

FILE1="/etc/network/interfaces"
FILE2="/etc/hosts"

echo "## nic0 adalah interface PVE host router yang menghadap ke ISP LAN ##"
echo "## vmbr0 adalah interface PVE host router yang menghadap ke private subnet container ##"
read -p "Enter nic0 address (e.g. 192.168.0.201): " nic0_IP
read -p "Enter nic0 prefix length (e.g. 24): " nic0_MASK
read -p "Enter nic0 gateway (e.g. 192.168.0.1): " nic0_GW
read -p "Enter vmbr0 new subnet address (e.g. 192.168.1.0): " vmbr0_SUBNET
read -p "Enter vmbr0 address (e.g. 192.168.1.1): " vmbr0_IP
read -p "Enter vmbr0 prefix length (e.g. 24): " vmbr0_MASK

# /etc/hosts
sed -i "/^127/! s|^[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*|${nic0_IP}|" "$FILE2"

# /etc/network/interfaces
cat > "$FILE1" <<EOF
auto lo
iface lo inet loopback

auto nic0
iface nic0 inet static
        address $nic0_IP/$nic0_MASK
        gateway $nic0_GW

source /etc/network/interfaces.d/*

auto vmbr0
iface vmbr0 inet static
        address $vmbr0_IP/$vmbr0_MASK
        bridge-ports none
        bridge-stp off
        bridge-fd 0
        post-up   echo 1 > /proc/sys/net/ipv4/ip_forward

        ## containers to ISP LAN and internet ##
        post-up   iptables -t nat -A POSTROUTING -s $vmbr0_SUBNET/$vmbr0_MASK -o nic0 -j MASQUERADE
        post-down iptables -t nat -D POSTROUTING -s $vmbr0_SUBNET/$vmbr0_MASK -o nic0 -j MASQUERADE
EOF

ifreload -a