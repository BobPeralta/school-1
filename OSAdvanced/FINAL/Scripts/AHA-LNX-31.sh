#!/bin/bash
# disable firewall:
sudo systemctl disable firewalld;
sudo systemctl stop firewalld;

echo "AHA-LNX-31" > "/etc/hostname";

# sudo reboot now;
exit;