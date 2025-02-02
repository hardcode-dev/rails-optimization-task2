# frozen_string_literal: true

require 'benchmark'
require 'memory_profiler'
require 'stackprof'
require 'ruby-prof'
require_relative 'reporter'


class Profiler
  FIXTURE_PATH = 'fixtures/data_smal_50000.txt'.freeze
  RESULT_PATH = 'fixtures/result.json'.freeze
  REPORTS_DIR = 'reports'
  
  class << self
    def make_report(reporter_type)
      send(reporter_type)
    end

    def memeory_prof
      report = MemoryProfiler.report do
        work(FIXTURE_PATH, RESULT_PATH)
      end
      report.pretty_print(scale_bytes: true)
    end

    def stack_prof
      StackProf.run(mode: :object, out: "#{REPORTS_DIR}/stackprof.dump", raw: true) do
        work(FIXTURE_PATH, RESULT_PATH)
      end
    end

    def ruby_prof
      RubyProf.measure_mode = RubyProf::MEMORY
      result = RubyProf.profile do
        work(FIXTURE_PATH, RESULT_PATH)
      end
      printer = RubyProf::CallTreePrinter.new(result)
      printer.print(path: REPORTS_DIR, profile: 'profile')
    end
  end
end

