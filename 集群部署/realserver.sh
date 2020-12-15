#!/bin/bash
ifconfig lo:0 192.168.2.162 broadcast 192.168.2.162 netmask 255.255.255.255 up
route add -host 192.168.2.162 dev lo:0
echo "1" > /proc/sys/net/ipv4/conf/lo/arp_ignore
echo "2" > /proc/sys/net/ipv4/conf/lo/arp_announce
echo "1" > /proc/sys/net/ipv4/conf/all/arp_ignore
echo "2" > /proc/sys/net/ipv4/conf/all/arp_announce
sysctl -p 
