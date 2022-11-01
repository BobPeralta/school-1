#!/bin/bash
# automatically install and run a PHP-website by copying files from an S3-bucket
sudo apt -y update
sudo apt -y install unzip apache2 php s3fs awscli

# S3 mounting
sudo mkdir /mnt/s3bucket
sudo aws s3fs s3BucketName: /mnt/s3bucket

# S3 copying files
sudo cp /mnt/s3bucket/index.php /var/www/html/index.php
sudo chmod 777 /var/www/html/index.php
