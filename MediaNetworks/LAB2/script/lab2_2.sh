#!/bin/bash
read -rp "Name your website (no spaces): " name;
read -rp "Enter your IP-address: " IP;
sleep 1;

echo -e "Updating";
sleep 1;
sudo apt -y update;
sudo apt -y upgrade;
sleep 1;

echo -e "";
echo -e "Installing nginx, libnginx-mod-rtmp and ffmpeg";
sleep 1;
sudo apt install -y nginx;
sudo apt install -y libnginx-mod-rtmp ffmpeg;
sleep 1;

echo -e "";
echo -e "Removing old nginx-config";
sudo mv "/etc/nginx/nginx.conf" "/etc/nginx/nginx.conf.bak"; > /dev/null 2>&1;
sleep 1;

echo -e "Configuring nginx";
sleep 1;
echo -e "
user www-data;
worker_processes auto;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

events {
    worker_connections  1024;
}

http {
        include mime.types;
        access_log /var/log/nginx/access.log;
        error_log /var/log/nginx/error.log;

        server {
                listen 80;
                # necessary headers
                location / {
                        expires -1;
                        add_header 'Cache-Control' 'no-cache';
                        add_header 'Access-Control-Allow-Origin' '*' always;
                        add_header 'Access-Control-Expose-Headers' 'Content-Length';
                        root /tmp;
                }
                # website for live playback and video playback
                location /$name {
                        index index.html index.htm index.php;
                        root /var/www;
                }
        }
}

rtmp {
        server {
                listen 1935;

                application live {
                        # live
                        live on;

                        # hls
                        hls on;
                        hls_path /tmp/hls;
                        hls_sync 100ms;
                        hls_cleanup on;

                        # allow playback
                        allow play all;

                        # record & transcode
                        record all;
                        record_path /var/www/$name/rec;
                        exec_record_done ffmpeg -y -i \$path -acodec libmp3lame -ar 44100 -ac 1 -vcodec libx264 /var/www/$name/rec/\$basename.mp4 -vframes 1 /var/www/$name/rec/\$basename.jpg;
                        # record_unique on;
                        # record_append on;
                }
        }
}
" >> "/etc/nginx/nginx.conf";
sleep 1;

echo -e "";
echo -e "Creating HLS-folder";
sleep 1;
sudo mkdir "/tmp/hls";  > /dev/null 2>&1;
sleep 1;

echo -e "";
echo -e "Removing any old website-files and folders.";
sudo rm -R "/var/www/$name"; > /dev/null 2>&1;
sleep 1;

echo -e "";
echo -e "Creating website folders";
sleep 1;
sudo mkdir "/var/www/$name"; > /dev/null 2>&1;
sudo mkdir "/var/www/$name/rec"; > /dev/null 2>&1;
sudo mkdir "/tmp/hls"; > /dev/null 2>&1;
sudo chmod 777 "/var/www/$name/rec";  > /dev/null 2>&1;
echo -e "
<!DOCTYPE html>
<html lang=\"en\">

<head>
    <link rel=\"stylesheet\" href=\"./video-js.css\" />
    <link rel=\"stylesheet\" href=\"./custom.css\" />
</head>

<body class=\"body\">
    <div class=\"wrapper\">
        <h1 class=\"input_Title\">Live Stream</h1>
        <div class=\"input\">
            <h1>Enter the video name you want:</h1>
            <input placeholder=\"No extensions\" type=\"text\" name=\"playbackName\" id=\"playbackName\" />
        </div>
        <button class=\"button_loadvideo\" id=\"playbackInput\">Load video</button>
        <video class=\"video\" id=\"playbackVideo\" src=\"http://$IP/$name/rec/Test.mp4\" controls></video>

        <h1 class=\"video-js_Title\">Live</h1>
        <video id=\"my-video\" class=\"video-js\" controls preload=\"auto\" poster=\"./poster.jpg\" data-setup=\"{}\">
            <source id=\"stream_ID\" src=\"http://$IP/hls/Test.m3u8\" type=\"application/vnd.apple.mpegurl\" />
        </video>
    </div>
    <script>
        document.getElementById('playbackInput').addEventListener('click', function () {
            let videoName = \"http://$IP/$name/rec/\" + document.getElementById('playbackName').value + \".mp4\";
            let thumbnail = \"http://$IP/$name/rec/\" + document.getElementById('playbackName').value + \".jpg\";
            document.getElementById('playbackVideo').setAttribute('src', videoName);
            document.getElementById('playbackVideo').setAttribute('poster', thumbnail);
        });
    </script>
    <script src=\"./video.min.js\"></script>
</body>

</html>
" >> "/var/www/$name/index.html";
sleep 1;

echo -e "";
echo -e "Downloading config-files to allow playback of .m3u8-files in-browser";
wget -q "https://raw.githubusercontent.com/Smile4Blitz/school/main/MediaNetworks/LAB2/website/custom.css"  > /dev/null 2>&1;
wget -q "https://raw.githubusercontent.com/Smile4Blitz/school/main/MediaNetworks/LAB2/website/video-js.css"  > /dev/null 2>&1;
wget -q "https://raw.githubusercontent.com/Smile4Blitz/school/main/MediaNetworks/LAB2/website/video.min.js"  > /dev/null 2>&1;
wget -q "https://github.com/Smile4Blitz/school/raw/main/MediaNetworks/LAB2/website/poster.jpg"  > /dev/null 2>&1;
sleep 1;

echo -e "Moving downloaded files";
sudo mv "custom.css" "/var/www/$name/custom.css";
sudo mv "video-js.css" "/var/www/$name/video-js.css";
sudo mv "video.min.js" "/var/www/$name/video.min.js";
sudo mv "poster.jpg" "/var/www/$name/poster.jpg";
sleep 1;

echo -e "";
echo -e "Restarting nginx";
sleep 1;
sudo systemctl restart nginx;
sleep 1;

echo -e "";
echo -e "Configuration options:";
echo -e "- HLS (HTTP Live Streaming) -files are stored in /tmp/hls";
echo -e "- You have to setup an OBS-stream first.";
echo -e "- OBS-settings: ";
echo -e "   - Server: rtmp://$IP/live";
echo -e "   - Stream-key: Test";
echo -e "- When OBS is streaming, go to: http://$IP/$name" ;
echo -e "";