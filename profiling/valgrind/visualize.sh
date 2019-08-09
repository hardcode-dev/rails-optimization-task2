#!/bin/bash

# brew cask install xquartz
# reboot
# On macOS with XQuartz, you will need to allow network connections to X11
# https://sourabhbajaj.com/blog/2017/02/07/gui-applications-docker-mac/

# open -a XQuartz

ip=$(ifconfig en0 | grep inet | awk '$1=="inet" {print $2}') && echo "IP: $ip"
xhost + ${ip}

docker run -d -ti \
    -e DISPLAY=${ip}:0 \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v $(pwd):/home/profiling \
    ruby/valgrind \
    massif-visualizer
