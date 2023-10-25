# memory_profiler (ruby 2.3.8+)
# allocated - total memory allocated during profiler run
# retained - survived after MemoryProfiler finished

require_relative '../spec/spec_helper'
# require 'benchmark'
require 'memory_profiler'
require_relative 'setup'

size = 10_000
file_path = fixture(size)
ensure_test_data_exists(size)

report = MemoryProfiler.report do
  work(Setup::FILE_PATH, disable_gc: false)
end
report.pretty_print(scale_bytes: true)
