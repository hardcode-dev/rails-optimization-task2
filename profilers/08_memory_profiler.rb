# ruby profilers/08_memory_profiler.rb
require_relative '../config/environment'

GC.disable

MemoryProfiler.start

Task.new(data_file_path: './spec/fixtures/data_100k.txt').work

report = MemoryProfiler.stop
report.pretty_print(scale_bytes: true)

result_file_path = 'data/result.json'
File.delete(result_file_path) if File.exist?(result_file_path)
