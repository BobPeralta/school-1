#!/bin/bash

echo "Starting...";

# disable firewall:
sudo systemctl disable firewalld;
sudo systemctl stop firewalld;

# static ip
ip a;
read -rp "Which interface is used for VLAN 57: ETH" VLAN57;
read -rp "Which interface is used for VLAN 58: ETH" VLAN58;

echo "AHA-LNX-20" > /etc/hostname;
echo "nameserver 10.11.8.10" > /tmp/resolv.conf;
sudo mv /tmp/resolv.conf /etc/resolv.conf;

{
echo -e "IPADDR='10.12.8.9/24'
BOOTPROTO='static'
STARTMODE='hotplug'"
} > /etc/sysconfig/network/ifcfg-eth$VLAN57;

{
echo -e "IPADDR='10.99.8.9/24'
BOOTPROTO='static'
STARTMODE='hotplug'"
} > /etc/sysconfig/network/ifcfg-eth$VLAN58;

# ip forwarding
echo -e "net.ipv4.ip_forward = 1" > /etc/sysctl.d/70-yast.conf;

# routes
echo -e "default 10.12.8.8 - eth$VLAN57" > /etc/sysconfig/network/ifroute-eth$VLAN57;
echo -e "default 10.12.8.8 - eth$VLAN57" > /etc/sysconfig/network/ifroute-eth$VLAN57.YaST2save;

sudo rcnetwork restart;
sleep 5;

# install extra packages
sudo zypper -n install dhcp-relay sysvinit-tools;

{
echo -e "# DHCP RELAY AGENT
DHCRELAY_INTERFACES=\"eth$VLAN57 eth$VLAN58\"
DHCRELAY_SERVERS=\"10.11.8.10\""
} > /etc/sysconfig/dhcrelay;

systemctl enable dhcp-relay;
systemctl restart dhcp-relay;

echo "Done...";
echo "Rebooting..";
sleep 5;

sudo reboot now;
exit;
