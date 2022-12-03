#/bin/bash
# static ip (not sure if ip forwarding gets enabled):
{
    echo -e "IPADDR='10.11.8.8/24'
BOOTPROTO='static'
STARTMODE='hotplug'"
} > /etc/sysconfig/network/ifcfg-eth0

{
    echo -e "IPADDR='10.12.8.8/24'
BOOTPROTO='static'
STARTMODE='hotplug'"
} > /etc/sysconfig/network/ifcfg-eth1

echo -e "default 10.11.8.1 - eth0" > /etc/sysconfig/network/ifroute-eth0;
echo -e "default 10.11.8.1 - eth0" > /etc/sysconfig/network/ifroute-eth0.YaST2save;
echo -e "10.99.8.0/24 10.12.8.9 - eth1" > /etc/sysconfig/network/ifroute-eth1;
echo -e "10.99.8.0/24 10.12.8.9 - eth1" > /etc/sysconfig/network/ifroute-eth1.YaST2save;
echo -e "10.99.8.0       10.12.8.9       255.255.255.0   eth1" > /etc/sysconfig/network/routes.YaST2save;

#     /etc/sysconfig/network/routes
echo "AHA-LNX-10" > "/etc/hostname";
echo "nameserver 10.11.8.10" > "/etc/resolv.conf";

# disable firewall:
sudo systemctl disable firewalld;
sudo systemctl stop firewalld;