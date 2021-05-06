# TMPfrozen_string_literal: true
require_relative 'task-2'
require 'benchmark'
require 'memory_profiler'
require 'stackprof'
require 'ruby-prof'
data_size = 50000


report = MemoryProfiler.report do 
    work("data/data#{data_size}.txt", true)
end
system("cd outputs && rm memory_profiler_*")
report.pretty_print(color_output: true, scale_bytes: true, to_file: "outputs/memory_profiler_#{Time.now.to_i}.txt")
system("cd outputs && ls memory_profiler_* |  xargs open")
 