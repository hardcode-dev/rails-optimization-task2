#!/bin/bash

docker run -it \
    -v $(pwd):/home/massif/test \
    -e DATA_FILE=data/data_large.txt \
    spajic/docker-valgrind-massif \
    valgrind --tool=massif ruby main.rb
