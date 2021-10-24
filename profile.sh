#!/bin/bash

docker run -it \
    -v $(pwd):/home/massif/test  \
    rails_optimization_task2/docker-valgrind-massif \
    valgrind --tool=massif ruby bin/runner.rb 500000
