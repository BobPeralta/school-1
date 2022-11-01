#!/bin/bash
# You need an S3-bucket and an EC2-instance with access to the S3-bucket (IAM)
# website files need to be on the S3-bucket
# you need an EFS files system which you can access from the EC2 (VPC / subnet / security groups)

# install and update
sudo apt -y update;
sudo apt -y install nginx awscli php8.1-fpm;

# install awscli
sudo aws s3 cp s3://bucketname/index.php /var/www/html/index.php;
sudo aws s3 cp s3://bucketname/default /etc/nginx/sites-available/default;

sudo systemctl enable nginx;
sudo systemctl restart nginx;

# creating html-file
echo "<h1>Public IP: $(curl ifconfig.me)</h1><h1>Hostname: $(hostname)</h1>" > /var/www/html/info.html;
