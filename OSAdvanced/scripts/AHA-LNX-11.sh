#!/bin/bash

echo "Starting...";

# disable firewall:
sudo systemctl disable firewalld;
sudo systemctl stop firewalld;

# static ip:

echo "AHA-LNX-11" > /etc/hostname;
echo "nameserver 10.11.8.10" > /tmp/resolv.conf;
sudo mv /tmp/resolv.conf /etc/resolv.conf;

{
echo -e "IPADDR='10.11.8.5/24'
BOOTPROTO='static'
STARTMODE='hotplug'"
} > /etc/sysconfig/network/ifcfg-eth0;

echo "default 10.11.8.8 - eth0" > /etc/sysconfig/network/ifroute-eth0;

# rsyslog
{
echo -e "# TCP syslog
module(load=\"imudp\")
input(type=\"imudp\" port=\"514\" ruleset=\"RemoteLogs\")

#UDP syslog
module(load=\"imtcp\")
input(type=\"imtcp\" port=\"514\" ruleset=\"RemoteLogs\")

# Where to store the logs
\$template Incoming-logs,\"/logs/%HOSTNAME%/%PROGRAMNAME%.log\"
ruleset(name=\"RemoteLogs\"){
action(type=\"omfile\" dynafile=\"Incoming-logs\")
}"
} > /etc/rsyslog.d/logs.conf;

sudo mkdir /logs;
sudo chmod -R 777 /logs;

sudo systemctl enable rsyslog;
sudo systemctl restart rsyslog;

echo "Done...";
echo "Rebooting..";
sleep 5;

sudo reboot now;
exit;
