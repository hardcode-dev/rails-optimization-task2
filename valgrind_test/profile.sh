#!/bin/bash

docker run -it \
    -v $(pwd):/home/massif/test \
    -e DATA_FILE=data_large.txt \
    lokideos/docker-valgrind-massif \
    valgrind --tool=massif ruby run.rb
