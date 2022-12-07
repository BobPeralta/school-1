#!/bin/bash

echo "Starting...";
echo "MAKE SURE YOUR ADAPTER IS SET ON THE CORRECT PORTGROUP";

# disable firewall
sudo systemctl disable firewalld;
sudo systemctl stop firewalld;

echo "AHA-LNX-31" > "/etc/hostname";

echo "Done...";
echo "Rebooting..";
sleep 5;

sudo reboot now;
exit;
