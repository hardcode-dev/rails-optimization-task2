#!/usr/bin/env sh

OUT_FILE=report/massif.out

valgrind --tool=massif --massif-out-file=$OUT_FILE ruby src/probe_memory.rb && massif-visualizer $OUT_FILE
