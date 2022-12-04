#!/bin/bash

echo "Starting...";

# disable firewall
sudo systemctl disable firewalld;
sudo systemctl stop firewalld;

echo "AHA-LNX-21" > "/etc/hostname";

echo "Done...";
sleep 1;
echo "Rebooting..";

sudo reboot now;
exit;