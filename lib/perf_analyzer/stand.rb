# frozen_string_literal: true

require 'benchmark'
require 'benchmark-trend'
require_relative 'runners/memory_profiler_runner'
require_relative 'runners/ruby_prof_runner'
require_relative 'runners/stackprof_runner'

module PerfAnalyzer
  # Run configured tools for performance analyze
  class Stand
    PROFILERS = {
      memory_profiler: Runners::MemoryProfilerRunner,
      ruby_prof: Runners::RubyProfRunner,
      stackprof: Runners::StackprofRunner
    }.freeze

    class << self
      def configure
        new.tap do |stand|
          yield(stand.config) if block_given?
        end
      end
    end

    attr_reader :config

    def initialize
      @config = default_config
    end

    def benchmark(start, limit, ratio: 8, &block)
      range = Benchmark::Trend.range(start, limit, ratio:)

      # warmup
      range.each(&block)

      results =
        range.map do |n|
          GC.start
          total = (Benchmark.measure { yield(n) }.total * 1000).to_i
          [n.to_s, "#{total}ms"]
        end
      results.to_h
    end

    def analyze(*profilers, &block)
      GC.disable if config[:gc_disable]

      run_profilers(profilers, &block)
    ensure
      GC.enable
    end

    private

    def run_profilers(profilers, &block)
      PROFILERS.slice(*profilers).each_with_object({}) do |(type, klass), results|
        results[type.to_s] = klass.new(config[:reports_dir]).run(**config[type], &block)
      end
    end

    def default_config # rubocop:disable Metrics/MethodLength
      {
        gc_disable: true,
        reports_dir: 'reports',
        memory_profiler: {
          # top: 50, # maximum number of entries to display in a report (default is 50)
          # allow_files: //, # include only certain files from tracing - can be given as a String, Regexp, or array of Strings
          # ignore_files: //, # exclude certain files from tracing - can be given as a String or Regexp
          # trace: [], # an array of classes for which you explicitly want to trace object allocations
        },
        ruby_prof: {
          track_allocations: true
        },
        stackprof: {
          mode: :wall,
          raw: true
        }
      }
    end
  end
end
