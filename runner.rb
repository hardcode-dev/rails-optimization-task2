# frozen_string_literal: true

require_relative 'task-2-flow'
require 'benchmark'
require 'memory_profiler'
require 'stackprof'
require 'ruby-prof'

size, mode, profiler = ARGV
FILENAME = "data/data#{size}.txt"

def memory_usage
  (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
end

def run_stackprof
  StackProf.run(mode: :object, out: 'stackprof_reports/stackprof.dump', raw: true) do
    work(FILENAME)
  end
end

def run_memory_profiler
  report = MemoryProfiler.report do
    work(FILENAME)
  end

  report.pretty_print(scale_bytes: true)
end

def run_ruby_prof(measure_mode)
  result = RubyProf::Profile.profile(track_allocations: true, measure_mode: measure_mode) do
    work(FILENAME)
  end

  printer = RubyProf::GraphHtmlPrinter.new(result)
  printer.print(File.open("ruby_prof_reports/graph_#{measure_mode}.html", 'w+'), :min_percent=>0)

  printer = RubyProf::CallStackPrinter.new(result)
  printer.print(File.open("ruby_prof_reports/callstack_#{measure_mode}.html", 'w+'))
end

def run_profiler(profiler)
  case profiler
  when 'stackprof'
    run_stackprof
  when 'memory_profiler'
    run_memory_profiler
  when 'ruby-prof-memory'
    run_ruby_prof(:memory)
  when 'ruby-prof-allocations'
    run_ruby_prof(:allocations)
  else
    puts "Unknown profiler type: #{profiler}"
  end
end

def run_memory_monitor
  puts format('INITIAL MEMORY USAGE: %d MB', memory_usage)

  monitor_thread = Thread.new do
    while true
      puts format('MEMORY USAGE: %d MB', memory_usage)
      sleep(1)
    end
  ensure
    puts format('FINAL MEMORY USAGE: %d MB', memory_usage)
  end

  work(FILENAME)
  monitor_thread.kill
end

run_memory_monitor if mode == 'memory'

puts Benchmark.measure { work(FILENAME) } if mode == 'time'

run_profiler(profiler) if mode == 'profile'
