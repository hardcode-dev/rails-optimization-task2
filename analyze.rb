# frozen_string_literal: true

require 'yaml'
require_relative 'lib/perf_analyzer/stand'
require_relative 'lib/perf_analyzer/loop'
require_relative 'task-2'

puts 'Enter experiment name (or leave empty):'
user_report_name = gets.chomp
report_time = Time.new.strftime('%y-%m-%d_%H-%M-%S')
report_name = user_report_name.empty? ? report_time : "#{report_time}_#{user_report_name}"
reports_dir = "reports/#{report_name}"
FileUtils.mkdir(reports_dir)

stand =
  PerfAnalyzer::Stand.configure do |config|
    config[:reports_dir] = reports_dir
    config[:ruby_prof] = {
      track_allocations: true,
      measure_mode: RubyProf::MEMORY
    }
    config[:stackprof] = {
      mode: :object,
      raw: true
    }
  end

loop = PerfAnalyzer::Loop.new(stand)

loop
  .analyze(:memory_profiler, :ruby_prof, :stackprof) { work('input/data_256k.txt') }
  .benchmark(1, 256, ratio: 2) { |n| work("input/data_#{n}k.txt") }
  .check_results
