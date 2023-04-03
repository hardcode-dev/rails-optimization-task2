#!/bin/bash

docker run -it \
    -v $(pwd):/home/massif/test \
    -e DATA_FILE=data/data_32_500.txt \
    maksimpw/valgrind \
    valgrind --tool=massif ruby work.rb
