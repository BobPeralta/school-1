#!/bin/bash
echo -e "Updating:";
sudo apt -qq -y update;
sudo apt -qq -y upgrade;

echo -e "";
echo -e "Installing required packages:";
sudo apt -qq -y install nginx libnginx-mod-rtmp ffmpeg build-essential;

echo -e "";
echo -e "Configuring NGINX: ";
echo -e "
user www-data;
worker_processes auto;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

events {
        worker_connections 768;
}

http {

        sendfile on;
        tcp_nopush on;
        types_hash_max_size 2048;

        include /etc/nginx/mime.types;
        default_type application/octet-stream;

        access_log /var/log/nginx/access.log;
        error_log /var/log/nginx/error.log;

        gzip on;

        include /etc/nginx/conf.d/*.conf;
        include /etc/nginx/sites-enabled/*;
}

rtmp {
        include /etc/nginx/rtmpconf.d/*.conf;
}
" > /etc/nginx/nginx.conf;

echo -e "";
echo -e "Configuring RTMP: ";
sudo mkdir /etc/nginx/rtmpconf.d > /dev/null 2>&1;
echo -e "
server {
        listen 1935;
        chunk_size 4096;

        application live {
              live on;
              record off;

              push rtmp://localhost/dash/;
              push rtmp://localhost/hls/;
        }

        application hls {
              allow publish 127.0.0.1;
              deny publish all;

              live on;
              record all;
              record_path /var/www/html/rec;
              exec_record_done ffmpeg -y -i $path -acodec libmp3lame -ar 44100 -ac 1 -vcodec libx264 /var/www/html/rec/$basename.mp4 -vframes 1 /var/www/html/rec/$basename.jpg;

              hls on;
              hls_path /var/www/html/hls;
              hls_fragment 3;
              hls_playlist_length 60;
        }
        application dash {
              allow publish 127.0.0.1;
              deny publish all;

              live on;
              record off;

              dash on;
              dash_path /var/www/html/dash;
        }
        application vod {
              play /var/www/html/rec;
        }
}
" > rtmpconf.d/streaming.conf;

echo -e "";
echo -e "Creating HTML-folders:";
sudo mkdir /var/www/html/hls;
sudo mkdir /var/www/html/dash;
sudo mkdir /var/www/html/rec;

sudo chmod 777 /var/www/html;
sudo chmod 777 /var/www/html/hls;
sudo chmod 777 /var/www/html/dash;
sudo chmod 777 /var/www/html/rec;

echo -e "";
echo -e "Downloading HTML-files:";
sudo rm -R /var/www/html/* > /dev/null 2>&1;

sudo wget https://raw.githubusercontent.com/dust555/MediaNetworks/main/HttpStreaming/dash.all.js > /dev/null 2>&1;
sudo wget https://raw.githubusercontent.com/dust555/MediaNetworks/main/HttpStreaming/dash.html > /dev/null 2>&1;
sudo wget https://raw.githubusercontent.com/dust555/MediaNetworks/main/HttpStreaming/dash.php > /dev/null 2>&1;
sudo wget https://raw.githubusercontent.com/dust555/MediaNetworks/main/HttpStreaming/hls.html > /dev/null 2>&1;
sudo wget https://raw.githubusercontent.com/dust555/MediaNetworks/main/HttpStreaming/hls.js > /dev/null 2>&1;
sudo wget https://raw.githubusercontent.com/dust555/MediaNetworks/main/HttpStreaming/hls.php > /dev/null 2>&1;

sudo mv dash.all.js /var/www/html > /dev/null 2>&1;
sudo mv dash.html /var/www/html > /dev/null 2>&1;
sudo mv dash.php /var/www/html > /dev/null 2>&1;
sudo mv hls.html /var/www/html > /dev/null 2>&1;
sudo mv hls.js /var/www/html > /dev/null 2>&1;
sudo mv hls.php /var/www/html > /dev/null 2>&1;

echo -e "";
read -rp "Would you like to create an SSL-certificate? (Y/N): " OK;
if [ "$OK" == Y ] || [ "$OK" == y ]
then
    read -rp "Enter your DDNS: " DDNS;
    echo "
    server {
        listen 80 default_server;
        listen [::]:80 default_server;

        root /var/www/html;

        index hsl.html;

        server_name $DDNS;

        location / {
              # First attempt to serve request as file, then
              # as directory, then fall back to displaying a 404.
              try_files \$uri \$uri/ =404;
        }
    }" > /etc/nginx/sites-available/default;
    sudo apt -qq -y install certbot python3-certbot-nginx;
    sudo certbot --nginx -d "$DDNS";
fi

echo -e "";
echo -e "Restarting nginx";
sudo systemctl restart nginx;