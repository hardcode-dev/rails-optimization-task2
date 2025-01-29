#!/bin/bash

docker run -it \
    -v $(pwd):/home/massif/test \
    -e DATA_FILE=data_large_64x.txt \
    spajic/docker-valgrind-massif \
    valgrind --tool=massif ruby task-2.rb
