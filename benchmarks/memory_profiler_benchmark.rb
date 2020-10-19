# frozen_string_literal: true

require 'memory_profiler'
require 'ruby-prof'
require 'benchmark'
require 'benchmark/memory'
require_relative '../task-2'

# RubyProf.measure_mode = RubyProf::ALLOCATIONS
# GC.compact
#
# rb_result = RubyProf.profile do
#   work('./spec/fixtures/data_10000.txt')
# end
#
# rb_printer = RubyProf::FlatPrinter.new(rb_result)
# rb_printer.print(File.open("reports/ruby_prof/alloc_flat_#{Time.now.to_i}.txt", 'w+'))
#
# RubyProf.measure_mode = RubyProf::MEMORY
# GC.compact
# rb_result = RubyProf.profile do
#   work('./spec/fixtures/data_10000.txt')
# end
#
# rb_printer = RubyProf::CallTreePrinter.new(rb_result)
# rb_printer.print(path: 'reports/ruby_prof/', profile: 'profile')
# GC.compact
# mp_report = MemoryProfiler.report do
#   work('./spec/fixtures/data_10000.txt')
#   # work('./data_large.txt')
# end
#
# mp_report.pretty_print
# GC.compact

Benchmark.memory do |x|
  x.report('work') { work('./spec/fixtures/data_10000.txt') }
end
