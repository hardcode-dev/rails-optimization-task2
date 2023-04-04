#!/bin/bash

if [ -z "${DATA_FILE}" ]; then
    DATA_FILE='data/data_32_500.txt'
fi

docker run -it \
    -v $(pwd):/home/massif/test \
    -e DATA_FILE=${DATA_FILE} \
    maksimpw/valgrind \
    valgrind --tool=massif ruby work.rb
