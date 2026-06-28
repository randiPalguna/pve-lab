#!/bin/bash

## nic0 adalah incoming interface PVE host router untuk masuk ke private subnet PVE container ## 

FILE1="/etc/network/interfaces"

read -p "Enter source protocol (e.g. tcp): " SRC_PROTO
read -p "Enter source port (e.g. 80): " SRC_PORT
read -p "Enter destination port (e.g. 80): " DST_PORT
read -p "Enter destination IP (e.g. 192.168.1.2): " DST_IP

# /etc/network/interfaces
cat >> "$FILE1" <<EOF

        ## ISP LAN with PROTO $SRC_PROTO, PORT $SRC_PORT -> containers with DST PORT $DST_PORT, DST IP $DST_IP  ##
        post-up   iptables -t nat -A PREROUTING -i nic0 -p $SRC_PROTO --dport $SRC_PORT -j DNAT --to-destination $DST_IP:$DST_PORT
        post-down iptables -t nat -D PREROUTING -i nic0 -p $SRC_PROTO --dport $SRC_PORT -j DNAT --to-destination $DST_IP:$DST_PORT
EOF

ifreload -a