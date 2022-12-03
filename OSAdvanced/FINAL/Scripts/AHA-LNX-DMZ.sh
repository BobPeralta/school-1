#/bin/bash
# static ip:
#     /etc/sysconfig/network/ifroute-eth0
#     /etc/sysconfig/network/ifcfg-eth0
#     /etc/resolv.conf

# disable firewall:
sudo systemctl disable firewalld;
sudo systemctl stop firewalld;

# install extra packages
zypper -n install nginx unzip rsyslog;

# website
sudo rm /srv/www/htdocs/* -R;
sudo rm /tmp* -R;

sudo wget https://github.com/Smile4Blitz/school/raw/main/OSAdvanced/FINAL/Website/FINAL.zip -P /tmp;
sudo unzip /tmp/FINAL.zip;

sudo mv /tmp/* /srv/www/htdocs;
chmod -R 777 /srv/www/htdocs;

# rsyslog setup
{
    echo -e "*.* @10.11.8.5"
} >> /etc/rsyslog.d/remote.conf

# enabling extra packages
systemctl enable nginx;
systemctl enable rsyslog;

systemctl restart nginx;
systemctl restart rsyslog;