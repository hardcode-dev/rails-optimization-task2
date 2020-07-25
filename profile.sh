#!/bin/bash

docker run -it --rm \
    -v $(pwd):/home/massif/test \
    -e DATA_FILE=tmp/data_80000.txt \
    spajic/docker-valgrind-massif \
    valgrind --tool=massif ruby work.rb
