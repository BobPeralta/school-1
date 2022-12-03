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
    echo -e "# TCP syslog
module(load="imudp")
input(type="imudp" port="514" ruleset="RemoteLogs")

#UDP syslog
module(load="imtcp")
input(type="imtcp" port="514" ruleset="RemoteLogs")

# Where to store the logs
$template Incoming-logs,"/logs/%HOSTNAME%/%PROGRAMNAME%.log"
ruleset(name="RemoteLogs"){
action(type="omfile" dynafile="Incoming-logs")
}"
} > /etc/rsyslog.d/logs.conf;

sudo mkdir /logs;
sudo chmod -R 777 /logs;

sudo systemctl enable rsyslog;
sudo systemctl restart rsyslog;