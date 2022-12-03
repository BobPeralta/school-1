#!/bin/bash
# disable firewall:
sudo systemctl disable firewalld;
sudo systemctl stop firewalld;

# static ip:

echo "AHA-LNX-DMZ" > "/etc/hostname";
echo "nameserver 10.11.8.10" > "/etc/resolv.conf";

#     /etc/sysconfig/network/ifroute-eth0

{
echo -e "IPADDR='10.10.8.100/24'
MTU='0'
BOOTPROTO='static'
STARTMODE='hotplug'"
} > /etc/sysconfig/network/ifcfg-eth0;

echo -e "default 10.10.8.1 - eth0" > /etc/sysconfig/network/ifroute-eth0;
echo -e "default 10.10.8.1 - eth0" > /etc/sysconfig/network/ifroute-eth0.YaST2save;

# install extra packages
sudo zypper -n install nginx unzip rsyslog;

# website
sudo rm "/srv/www/htdocs/*" -R;
sudo rm "/tmp/*" -R;

sudo wget https://github.com/Smile4Blitz/school/raw/main/OSAdvanced/FINAL/Website/FINAL.zip -P /tmp;
sudo unzip "/tmp/FINAL.zip";

sudo mv "/tmp/*" "/srv/www/htdocs";
chmod -R 777 "/srv/www/htdocs";

# rsyslog setup
{
echo -e "*.* @10.11.8.5"
} > "/etc/rsyslog.d/remote.conf"

# enabling extra packages
systemctl enable nginx;
systemctl enable rsyslog;

systemctl restart nginx;
systemctl restart rsyslog;

# sudo reboot now;
exit;