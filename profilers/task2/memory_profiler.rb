require_relative 'helper'

report = MemoryProfiler.report do
  Optimization::TaskTwo.work("#{@root}data/dataN.txt", true)
end

report.pretty_print(scale_bytes: true)
