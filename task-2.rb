require_relative "./lib/user.rb"
require 'memory_profiler'

report = MemoryProfiler.report do
  work(input_path: "./data/data_sample.txt", output_path: "./result.json")
end
report.pretty_print(scale_bytes: true)
