#!/bin/bash
# automatically install and run a PHP-website by copying files from an S3-bucket
sudo apt -y update
sudo apt -y install unzip apache2 php s3fs awscli

# S3 access credentials
echo AKIAVTKT7QKTCZZKDWMC:VV+9jA1i3zcy1RlIIHz2vwPpNjKUBc78f5sJx2x8 > /home/ubuntu/.s3fs-creds
chmod 600 /home/ubuntu/.s3fs-creds

# S3 mounting
sudo mkdir /mnt/s3bucket
sudo s3fs arnohalsberghe: /mnt/s3bucket -o passwd_file=/home/ubuntu/.s3fs-creds,nonempty

# S3 copying files
sudo cp /mnt/s3bucket/index.php /var/www/html/index.php
sudo chmod 777 /var/www/html/index.php