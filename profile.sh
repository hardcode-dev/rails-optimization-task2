#!/bin/bash

docker run -it \
    -v $(pwd):/home/massif/test \
    -e DATA_FILE=fixtures/data_large.txt \
    spajic/docker-valgrind-massif \
    valgrind --tool=massif ruby work.rb
