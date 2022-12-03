#/bin/bash
# static ip (not sure if ip forwarding gets enabled):

ip a;
read -rp "Which interface is used for VLAN 56: ETH" VLAN56;
read -rp "Which interface is used for VLAN 57: ETH" VLAN57;

{
    echo -e "IPADDR='10.11.8.8/24'
BOOTPROTO='static'
STARTMODE='hotplug'"
} > /etc/sysconfig/network/ifcfg-eth$VLAN56;

{
    echo -e "IPADDR='10.12.8.8/24'
BOOTPROTO='static'
STARTMODE='hotplug'"
} > /etc/sysconfig/network/ifcfg-eth$VLAN57;

echo -e "default 10.11.8.1 - eth0" > /etc/sysconfig/network/ifroute-eth$VLAN56;
echo -e "default 10.11.8.1 - eth0" > /etc/sysconfig/network/ifroute-eth$VLAN56.YaST2save;
echo -e "10.99.8.0/24 10.12.8.9 - eth1" > /etc/sysconfig/network/ifroute-eth$VLAN57;
echo -e "10.99.8.0/24 10.12.8.9 - eth1" > /etc/sysconfig/network/ifroute-eth$VLAN57.YaST2save;
echo -e "10.99.8.0       10.12.8.9       255.255.255.0   eth1" > /etc/sysconfig/network/routes.YaST2save;

#     /etc/sysconfig/network/routes
echo "AHA-LNX-10" > "/etc/hostname";
echo "nameserver 10.11.8.10" > "/etc/resolv.conf";

# disable firewall:
sudo systemctl disable firewalld;
sudo systemctl stop firewalld;