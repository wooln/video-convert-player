# 视频网页播放器&m3u8转码脚本

## 视频网页播放器
- 部署webapp目录为网站的根，设置好ts、m3u8扩展名的MIME类型
- 播放m3u8视频：/player/m3u8.html?title=标题&src=m3u8视频主索引地址&poster=封面
- 播放普通h264编码的视频如mp4：/player/h264.html?title=标题&src=m3u8视频主索引地址&poster=封面

## m3u8转码脚本
- 转码安装ffmpeg，本地测试安装http-server（npm）
- 把要转码的文件放入video-hls-convert/videos目录
- 运行hls脚本`cd video-hls-convert`  `./hls.sh`，转码后的目录在video-hls-convert/target目录，360/480/720p
- 运行http-server . -o 进行测试