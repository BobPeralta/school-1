#/bin/bash
# disable firewall:
sudo systemctl disable firewalld;
sudo systemctl stop firewalld;

# static ip:
#     /etc/sysconfig/network/ifroute-eth0
#     /etc/sysconfig/network/ifcfg-eth0
#     /etc/resolv.conf

# rsyslog
{
    echo -e ""
} > /etc/rsyslog.d/logs.conf;

sudo mkdir /logs;
sudo chmod -R 777 /logs;

sudo systemctl enable rsyslog;
sudo systemctl restart rsyslog;