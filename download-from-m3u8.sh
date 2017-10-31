#!/bin/bash

# execute as:
#	./download-from-m3u8 http://host/path/to/file.m3u8 filename

ffmpeg -i "$1" -c copy -bsf:a aac_adtstoasc $2.mp4
