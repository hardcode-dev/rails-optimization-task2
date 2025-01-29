#!/usr/bin/env bash

set -e

rspec task-2_spec.rb -e 'parser works'
ruby analyze.rb
rm result.json