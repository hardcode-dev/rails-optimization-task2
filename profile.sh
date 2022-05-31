#!/bin/bash

docker run -it \
    -v $(pwd):/home/massif/test \
    -e DATA_FILE=data1000000.txt \
    spajic/docker-valgrind-massif \
    valgrind --tool=massif ruby work.rb
