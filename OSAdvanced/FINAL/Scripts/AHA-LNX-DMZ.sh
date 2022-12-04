#!/bin/bash
# disable firewall:
echo "starting";
sudo systemctl disable firewalld;
sudo systemctl stop firewalld;

# static ip:
echo "AHA-LNX-DMZ" > /etc/hostname;

echo "nameserver 10.11.8.10" > resolv.conf;
sudo mv resolv.conf /etc;

{
echo -e "IPADDR='10.10.8.100/24'
MTU='0'
BOOTPROTO='static'
STARTMODE='hotplug'"
} > /etc/sysconfig/network/ifcfg-eth0;

echo -e "default 10.10.8.1 - eth0" > /etc/sysconfig/network/ifroute-eth0;
echo -e "default 10.10.8.1 - eth0" > /etc/sysconfig/network/ifroute-eth0.YaST2save;

sudo rcnetwork restart;
sleep 2;

# install extra packages
sudo zypper -n install nginx unzip rsyslog > /dev/null;

# website
sudo rm -R /srv/www/htdocs/* > /dev/null;
sudo rm -R /tmp/* > /dev/null;

sudo wget "https://github.com/Smile4Blitz/school/raw/main/OSAdvanced/FINAL/Website/FINAL.zip" -P /tmp;
sudo unzip -qq -o /tmp/FINAL.zip -d /tmp;
sudo rm /tmp/FINAL.zip;

sudo mv /tmp/* /srv/www/htdocs;
chmod -R 777 /srv/www/htdocs;

{
echo -e "
server {
        listen       8080;
        server_name  AHA-LNX-DMZ;
location / {
        root   /srv/www/htdocs/;
            index  index.html;
        }
}"
} > /etc/nginx/conf.d/website.conf;

# rsyslog setup
{
echo -e "*.* @10.11.8.5"
} > /etc/rsyslog.d/remote.conf

# enabling extra packages
systemctl enable nginx;
systemctl enable rsyslog;

systemctl restart nginx;
systemctl restart rsyslog;

#sudo reboot now;
exit;