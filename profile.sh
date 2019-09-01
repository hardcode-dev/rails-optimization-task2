#!/bin/bash

docker run -it \
    -v $(pwd):/home/massif/test \
    spajic/docker-valgrind-massif \
    valgrind --tool=massif ruby work.rb
