#!/bin/bash

#
# NOTE: On macOS with XQuartz, you will need to allow network connections to X11
#

docker run -d -ti --rm \
    -e DISPLAY=docker.for.mac.host.internal:0 \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v $(pwd):/home/massif/test \
    spajic/docker-valgrind-massif \
    massif-visualizer
