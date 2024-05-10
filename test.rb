#!/usr/bin/env ruby

require_relative 'task-2'

# # ======== MEMORY PROFILER =========
# require 'memory_profiler'

# report = MemoryProfiler.report do
#   work(File.join(__dir__, ARGV.first))
# end
# report.pretty_print(scale_bytes: true)
# # ==================

# ==================
require 'stackprof'

StackProf.run(mode: :object, out: 'stackprof_reports/stackprof.dump', raw: true) do
  work(File.join(__dir__, ARGV.first))
end
# ==================
