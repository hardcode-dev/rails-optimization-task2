# frozen_string_literal: true

require 'memory_profiler'
require_relative 'base'

module PerfAnalyzer
  module Runners
    # :nodoc:
    class MemoryProfilerRunner < Base
      def run(**options, &block)
        result = MemoryProfiler.report(**options, &block)
        result.pretty_print(to_file: "#{@report_dir}/memory_profiler.txt")
        {
          'total_allocated_memsize' => result.total_allocated_memsize,
          'total_allocated' => result.total_allocated,
          'total_retained_memsize' => result.total_retained_memsize,
          'total_retained' => result.total_retained
        }
      end
    end
  end
end

