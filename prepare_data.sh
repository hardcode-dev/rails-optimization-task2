#!/usr/bin/env bash

gunzip data_large.txt.gz -k > input/data_large.txt
head -n 1000 input/data_large.txt > input/data_1k.txt
head -n 2000 input/data_large.txt > input/data_2k.txt
head -n 4000 input/data_large.txt > input/data_4k.txt
head -n 8000 input/data_large.txt > input/data_8k.txt
head -n 16000 input/data_large.txt > input/data_16k.txt
head -n 32000 input/data_large.txt > input/data_32k.txt
head -n 64000 input/data_large.txt > input/data_64k.txt
head -n 128000 input/data_large.txt > input/data_128k.txt
head -n 256000 input/data_large.txt > input/data_256k.txt