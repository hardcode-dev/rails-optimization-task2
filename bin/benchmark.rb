#!/usr/bin/env ruby

# frozen_string_literal: true

require 'benchmark'
require_relative '../lib/profiler'


time = Benchmark.realtime do
  work('fixtures/data_large.txt', 'result.json', { watcher_enable: true })
end



def printer(time, rows = 1000)
  pp "Processing time from file: #{time.round(4)}" 
end

printer(time)


