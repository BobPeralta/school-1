#!/bin/bash

echo "Starting...";

# disable firewall
sudo systemctl disable firewalld;
sudo systemctl stop firewalld;

echo "AHA-LNX-21" > "/etc/hostname";

echo "Done...";
echo "Rebooting..";
sleep 5;

sudo reboot now;
exit;
