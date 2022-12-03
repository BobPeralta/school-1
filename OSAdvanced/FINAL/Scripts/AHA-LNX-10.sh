#/bin/bash
# static ip (not sure if ip forwarding gets enabled):
{
    echo -e ""
}
#     /etc/sysconfig/network/ifroute-eth0
#     /etc/sysconfig/network/ifcfg-eth0
#     /etc/sysconfig/network/ifroute-eth1
#     /etc/sysconfig/network/ifcfg-eth1
#     /etc/sysconfig/network/routes
echo "AHA-LNX-10" > "/etc/hostname";
echo "nameserver 10.11.8.10" > "/etc/resolv.conf";

# disable firewall:
sudo systemctl disable firewalld;
sudo systemctl stop firewalld;