#!/bin/bash
read -rp "Enter server-IP (not the proxy): " IP;
echo -e "Updating";
sudo apt -qq -y update;
sudo apt -qq -y upgrade;

echo -e "";
echo -e "Installing required packages";
sudo apt -qq -y install nginx;

echo -e "";
echo -e "Configuring NGINX";
sleep 1;
echo -e "
# nginx-proxy
proxy_cache_path /var/www/cache levels=1:2 keys_zone=my_cache:10m
max_size=10g
inactive=60m use_temp_path=off;

server {
        listen 80 default_server;
        listen [::]:80 default_server;
        add_header X-CACHE-STATUS \$UPSTREAM_CACHE_STATUS;
        proxy_set_header X-REQUEST-ID \$REQUEST_ID;

        index index.html index.htm index.nginx-debian.html;

        server_name _;

        location / {
                proxy_cache my_cache;
                proxy_cache_valid 200 301 302;
                proxy_pass http://$IP;
        }
}" > default;
sudo mv default /etc/nginx/sites-available/default;

echo -e "Creating Proxy-folder";
sleep 1;
sudo mkdir /var/www/proxy;
sudo chmod 777 /var/www/proxy;

echo "";
echo -e "Restarting nginx";
sudo systemctl restart nginx;
exit 0;