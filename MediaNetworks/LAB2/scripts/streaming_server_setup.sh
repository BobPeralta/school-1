#!/bin/bash
echo -e "";
echo -e "Updating";
sleep 1;
sudo apt -y update;
sudo apt -y upgrade;
sleep 1;

echo -e "";
echo -e "Installing nginx and libnginx-mod-rtmp";
sleep 1;
sudo apt install -y nginx;
sudo apt install -y libnginx-mod-rtmp;
sleep 1;

echo -e "";
read -p "Name your website (no spaces): " name;
read -p "Enter your IP-address: " IP;
sleep 1;

echo -e "";
echo -e "Removing old nginx-config"
sudo mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak;
echo -e "done";
sleep 1;

echo "";
echo -e "Configuring nginx";
sleep 1;
echo -e "user www-data;" >> /etc/nginx/nginx.conf;
echo -e "worker_processes auto;" >> /etc/nginx/nginx.conf;
echo -e "pid /run/nginx.pid;" >> /etc/nginx/nginx.conf;
echo -e "include /etc/nginx/modules-enabled/*.conf;" >> /etc/nginx/nginx.conf;
echo -e "events {" >> /etc/nginx/nginx.conf;
echo -e "    worker_connections  1024;" >> /etc/nginx/nginx.conf;
echo -e "}" >> /etc/nginx/nginx.conf;
echo -e "" >> /etc/nginx/nginx.conf;
echo -e "http {" >> /etc/nginx/nginx.conf;
echo -e "        keepalive_timeout 65;" >> /etc/nginx/nginx.conf;
echo -e "        sendfile on;" >> /etc/nginx/nginx.conf;
echo -e "        tcp_nopush on;" >> /etc/nginx/nginx.conf;
echo -e "        tcp_nodelay on;" >> /etc/nginx/nginx.conf;
echo -e "        directio 512;" >> /etc/nginx/nginx.conf;
echo -e "" >> /etc/nginx/nginx.conf;
echo -e "        default_type application/octet-stream;" >> /etc/nginx/nginx.conf;
echo -e "" >> /etc/nginx/nginx.conf;
echo -e "        access_log /var/log/nginx/access.log;" >> /etc/nginx/nginx.conf;
echo -e "        error_log /var/log/nginx/error.log;" >> /etc/nginx/nginx.conf;
echo -e "" >> /etc/nginx/nginx.conf;
echo -e "        gzip on;" >> /etc/nginx/nginx.conf;
echo -e "" >> /etc/nginx/nginx.conf;
echo -e "        include /etc/nginx/mime.types;" >> /etc/nginx/nginx.conf;
echo -e "" >> /etc/nginx/nginx.conf;
echo -e "        server {" >> /etc/nginx/nginx.conf;
echo -e "                listen 80;" >> /etc/nginx/nginx.conf;
echo -e "                location / {" >> /etc/nginx/nginx.conf;
echo -e "                        # Disable cache" >> /etc/nginx/nginx.conf;
echo -e "                        add_header 'Cache-Control' 'no-cache';" >> /etc/nginx/nginx.conf;
echo -e "                        # CORS setup" >> /etc/nginx/nginx.conf;
echo -e "                        add_header 'Access-Control-Allow-Origin' '*' always;" >> /etc/nginx/nginx.conf;
echo -e "                        add_header 'Access-Control-Expose-Headers' 'Content-Length';" >> /etc/nginx/nginx.conf;
echo -e "                        # allow CORS preflight requests" >> /etc/nginx/nginx.conf;
echo -e "                        if (\$request_method = 'OPTIONS') {" >> /etc/nginx/nginx.conf;
echo -e "                                add_header 'Access-Control-Allow-Origin' '*';" >> /etc/nginx/nginx.conf;
echo -e "                                add_header 'Access-Control-Max-Age' 1728000;" >> /etc/nginx/nginx.conf;
echo -e "                                add_header 'Content-Type' 'text/plain charset=UTF-8';" >> /etc/nginx/nginx.conf;
echo -e "                                add_header 'Content-Length' 0;" >> /etc/nginx/nginx.conf;
echo -e "                                return 204;" >> /etc/nginx/nginx.conf;
echo -e "                        }" >> /etc/nginx/nginx.conf;
echo -e "                        types {" >> /etc/nginx/nginx.conf;
echo -e "                                application/dash+xml mpd;" >> /etc/nginx/nginx.conf;
echo -e "                                application/vnd.apple.mpegurl m3u8;" >> /etc/nginx/nginx.conf;
echo -e "                                video/mp2t ts;" >> /etc/nginx/nginx.conf;
echo -e "                        }" >> /etc/nginx/nginx.conf;
echo -e "                        root /mnt;" >> /etc/nginx/nginx.conf;
echo -e "                }" >> /etc/nginx/nginx.conf;
echo -e "                location /$name {" >> /etc/nginx/nginx.conf;
echo -e "                        index index.html index.htm index.php;" >> /etc/nginx/nginx.conf;
echo -e "                        root /var/www;" >> /etc/nginx/nginx.conf;
echo -e "                }" >> /etc/nginx/nginx.conf;
echo -e "        }" >> /etc/nginx/nginx.conf;
echo -e "}" >> /etc/nginx/nginx.conf;
echo -e "" >> /etc/nginx/nginx.conf;
echo -e "# RTMP configuration" >> /etc/nginx/nginx.conf;
echo -e "rtmp {" >> /etc/nginx/nginx.conf;
echo -e "        server {" >> /etc/nginx/nginx.conf;
echo -e "                listen 1935; # Listen on standard RTMP port" >> /etc/nginx/nginx.conf;
echo -e "                chunk_size 4000;" >> /etc/nginx/nginx.conf;
echo -e "" >> /etc/nginx/nginx.conf;
echo -e "        application live {" >> /etc/nginx/nginx.conf;
echo -e "                live on;" >> /etc/nginx/nginx.conf;
echo -e "                record off;" >> /etc/nginx/nginx.conf;
echo -e "                # Turn on HLS" >> /etc/nginx/nginx.conf;
echo -e "                hls on;" >> /etc/nginx/nginx.conf;
echo -e "                hls_path /mnt/hls;" >> /etc/nginx/nginx.conf;
echo -e "                hls_fragment 3;" >> /etc/nginx/nginx.conf;
echo -e "                hls_playlist_length 60;" >> /etc/nginx/nginx.conf;
echo -e "                # disable consuming the stream from nginx as rtmp" >> /etc/nginx/nginx.conf;
echo -e "                # deny play all;" >> /etc/nginx/nginx.conf;
echo -e "                }" >> /etc/nginx/nginx.conf;
echo -e "        }" >> /etc/nginx/nginx.conf;
echo -e "}" >> /etc/nginx/nginx.conf;
echo -e "done";
sleep 1;

echo -e "";
echo -e "Creating HLS-folder";
sleep 1;
sudo mkdir /mnt/hls;
echo -e "done";
sleep 1;

echo -e "";
echo -e "Removing any old website-files and folders.";
sudo rm -R /var/www/$name;
sleep 1;

echo -e "";
echo -e "Creating website folder ($name)";
sleep 1;
sudo mkdir /var/www/$name;
echo -e "done";
sleep 1;

echo -e "";
echo -e "Creating index page";
sleep 1;
echo -e "<!DOCTYPE html>" >> /var/www/arno/index.html
echo -e "<html lang=\"en\">" >> /var/www/arno/index.html
echo -e "" >> /var/www/arno/index.html
echo -e "<head>" >> /var/www/arno/index.html
echo -e "    <link rel=\"stylesheet\" href=\"./video-js.css\" />" >> /var/www/arno/index.html
echo -e "    <link rel=\"stylesheet\" href=\"./custom.css\" />" >> /var/www/arno/index.html
echo -e "</head>" >> /var/www/arno/index.html
echo -e "" >> /var/www/arno/index.html
echo -e "<body class=\"body\">" >> /var/www/arno/index.html
echo -e "    <div class=\"wrapper\">" >> /var/www/arno/index.html
echo -e "        <h1 class=\"input_Title\">Live Stream</h1>" >> /var/www/arno/index.html
echo -e "        <div class=\"input\">" >> /var/www/arno/index.html
echo -e "            <h1>Enter the video name you want:</h1>" >> /var/www/arno/index.html
echo -e "            <input placeholder=\"No extensions\" type=\"text\" name=\"playbackName\" id=\"playbackName\" />" >> /var/www/arno/index.html
echo -e "        </div>" >> /var/www/arno/index.html
echo -e "        <button class=\"button_loadvideo\" id=\"playbackInput\">Load video</button>" >> /var/www/arno/index.html
echo -e "        <video class=\"video\" id=\"playbackVideo\" src=\"http://$IP/$name/rec/Test.mp4\" controls></video>" >> /var/www/arno/index.html
echo -e "" >> /var/www/arno/index.html
echo -e "        <h1 class=\"video-js_Title\">Live</h1>" >> /var/www/arno/index.html
echo -e "        <video id=\"my-video\" class=\"video-js\" controls preload=\"auto\" poster=\"./poster.jpg\" data-setup=\"{}\">" >> /var/www/arno/index.html
echo -e "            <source id=\"stream_ID\" src=\"http://$IP/hls/Test.m3u8\" type=\"application/vnd.apple.mpegurl\" />" >> /var/www/arno/index.html
echo -e "        </video>" >> /var/www/arno/index.html
echo -e "    </div>" >> /var/www/arno/index.html
echo -e "    <script>" >> /var/www/arno/index.html
echo -e "        document.getElementById('playbackInput').addEventListener('click', function () {" >> /var/www/arno/index.html
echo -e "            let videoName = \"http://$IP/$name/rec/\" + document.getElementById('playbackName').value + \".mp4\";" >> /var/www/arno/index.html
echo -e "            let thumbnail = \"http://$IP/$name/rec/\" + document.getElementById('playbackName').value + \".jpg\";" >> /var/www/arno/index.html
echo -e "            document.getElementById('playbackVideo').setAttribute('src', videoName);" >> /var/www/arno/index.html
echo -e "            document.getElementById('playbackVideo').setAttribute('poster', thumbnail);" >> /var/www/arno/index.html
echo -e "        });" >> /var/www/arno/index.html
echo -e "    </script>" >> /var/www/arno/index.html
echo -e "    <script src=\"./video.min.js\"></script>" >> /var/www/arno/index.html
echo -e "</body>" >> /var/www/arno/index.html
echo -e "" >> /var/www/arno/index.html
echo -e "</html>" >> /var/www/arno/index.html
echo -e "done";
sleep 1;

echo -e "";
echo -e "Downloading config-files to allow playback of .m3u8-files in-browser";
wget -q "https://vjs.zencdn.net/7.20.3/video-js.css";
wget -q "https://vjs.zencdn.net/7.20.3/video.min.js";
wget -q "https://netflixjunkie.com/wp-content/uploads/2021/07/the-witcher-trivia-and-interesting-facts-you-didnt-know-1140x600.jpg";
sudo mv "video-js.css" /var/www/$name/video-js.css;
sudo mv "video.min.js" /var/www/$name/video.min.js;
sudo mv "the-witcher-trivia-and-interesting-facts-you-didnt-know-1140x600.jpg" /var/www/$name/poster.jpg;
echo -e "done";
sleep 1;

echo -e "";
echo -e "Restarting nginx"
sleep 1;
sudo systemctl restart nginx;
echo -e "done";
sleep 1;

echo -e "";
echo -e "Configuration options:";
echo -e "- HLS (HTTP Live Streaming) -files are stored in /mnt/hls"
echo -e "- You have to setup an OBS-stream first."
echo -e "- OBS-settings: ";
echo -e "   - Server: rtmp://$IP/live";
echo -e "   - Stream-key: Test";
echo -e "- When OBS is streaming, go to: http://$IP/$name" ;
echo -e "";