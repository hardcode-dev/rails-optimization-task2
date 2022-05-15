#!/bin/bash

docker run -it \
    -v $(pwd):/home/massif/test \
    -e DATA_FILE=data/data_18.txt \
    spajic/docker-valgrind-massif \
    valgrind --tool=massif ruby task-2.rb
