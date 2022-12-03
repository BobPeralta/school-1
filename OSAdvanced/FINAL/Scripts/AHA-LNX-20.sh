#/bin/bash
# disable firewall:
sudo systemctl disable firewalld;
sudo systemctl stop firewalld;

# static ip
ip a;
read -rp "Which interface is used for VLAN 57: ETH" VLAN57;
read -rp "Which interface is used for VLAN 58: ETH" VLAN58;

echo "AHA-LNX-20" > "/etc/hostname";
echo "nameserver 10.11.8.10" > "/etc/resolv.conf";

# /etc/sysconfig/network/ifcfg-eth0
# /etc/sysconfig/network/ifcfg-eth1

# ip forwarding
echo -e "net.ipv4.ip_forward = 1" > /etc/sysctl.d/70-yast.conf;

# routes
# /etc/sysconfig/network/ifroute-eth0
# /etc/sysconfig/network/ifroute-eth0.YaST2save
# /etc/sysconfig/network/ifroute-eth1
# /etc/sysconfig/network/ifroute-eth1.YaST2save

# install extra packages
sudo zypper -n install dhcp-relay sysvinit-tools;

{
echo -e "# DHCP RELAY AGENT
DHCRELAY_INTERFACES=\"eth0 eth1\"
DHCRELAY_SERVERS=\"10.11.8.10\""
} > /etc/sysconfig/dhcrelay;

systemctl enable dhcp-relay;
systemctl restart dhcp-relay;

sudo reboot now;
exit;