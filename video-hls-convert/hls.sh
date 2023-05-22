#!/bin/bash

for file in videos/*
do
    if [[ $file =~ \.(mp4|mov|flv|VOB)$ ]] # 筛选特定视频格式的后周
    then
        title=${file%.*}
        echo $title
        # title=${file:0:2} #取title前两位
        out_dir="target/$title"
        if [ ! -d "target/$title" ]; then
            echo 创建目录$out_dir
            mkdir -p $out_dir
            
            # 生产主视频索引
            cat <<EOF > "$out_dir/v.m3u8"
#EXTM3U
#EXT-X-VERSION:3
#EXT-X-STREAM-INF:BANDWIDTH=800000,RESOLUTION=640x360
./360p.m3u8
#EXT-X-STREAM-INF:BANDWIDTH=1300000,RESOLUTION=842x480
./480p.m3u8
#EXT-X-STREAM-INF:BANDWIDTH=2600000,RESOLUTION=1280x720
./720p.m3u8
EOF
            #生产html播放
            cat <<EOF > "$out_dir/index.html"
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>hls-demo</title>
    <style>
      #video {
        display: block;
        margin: 0 auto;
      }
    </style>
  </head>
  <body>
    <video id="video" width="500" controls></video>
  </body>
  <script src="https://cdn.jsdelivr.net/npm/hls.js@latest"></script>
  <script>
    var video = document.getElementById('video');
    var m3u8 = "v.m3u8";
    if (Hls.isSupported()) {
      var hls = new Hls();
      hls.loadSource(m3u8);
      hls.attachMedia(video);
      hls.on(Hls.Events.MANIFEST_PARSED, function() {
        video.play();
      });
    } else if (video.canPlayType('application/vnd.apple.mpegurl')) {
      video.src = m3u8;
      video.addEventListener('loadedmetadata', function() {
        video.play();
      });
    }
  </script>
</html>
EOF
        fi
        
        #压制视频
        ffmpeg -v verbose -i $file \
        -vf scale=640:360 -c:a aac -c:v libx264 \
        -hls_time 10 \
        -hls_playlist_type vod -b:v 400k -maxrate 400k -bufsize 400k -b:a 96k \
        -hls_segment_filename $out_dir/360p_%03d.ts -f hls $out_dir/360p.m3u8 \
        -vf scale=854x480 -c:a aac -c:v libx264 \
        -hls_time 10 \
        -hls_playlist_type vod -b:v 800k -maxrate 800k -bufsize 800k -b:a 128k \
        -hls_segment_filename $out_dir/480p_%03d.ts $out_dir/480p.m3u8 \
        -vf scale=1280:720 -c:a aac -c:v libx264 \
        -hls_time 10 \
        -hls_playlist_type vod -b:v 1500k -maxrate 1500k -bufsize 1500k -b:a 256k \
        -hls_segment_filename $out_dir/720p_%03d.ts $out_dir/720p.m3u8
        
    fi
done