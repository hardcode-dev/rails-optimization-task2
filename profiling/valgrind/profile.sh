#!/bin/bash

docker run -it \
    -v $(pwd):/home/profiling \
    ruby/valgrind \
    valgrind --tool=massif --massif-out-file=/home/profiling/profiling/valgrind/massif.out.1 ruby profiling/valgrind/profile.rb
