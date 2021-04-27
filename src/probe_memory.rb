# frozen_string_literal: true

FILE_NAME_LARGE = 'data_large.txt'
REPORT_PATH = './report'
LIMIT = 200_000
NO_LIMIT = nil

OPEN_CMD = RUBY_PLATFORM =~ /darwin/ ? 'open' : 'xdg-open'

require 'memory_profiler'
require 'ruby-prof'
require 'stackprof'

require_relative 'work.rb'

def do_work(limit: LIMIT)
  work(limit: limit, file_name: FILE_NAME_LARGE)
end

at_exit do
  puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
end

def memory_profiler
  MemoryProfiler.report do
    do_work
  end.pretty_print(scale_bytes: true)
end

def stackprof
  StackProf.run(mode: :object, out: "#{REPORT_PATH}/stackprof.dump", raw: true) do
    do_work
  end
end

def ruby_prof(measure_mode)
  RubyProf.measure_mode = measure_mode
  result = RubyProf.profile { do_work }

  {
    'flat.txt' => RubyProf::FlatPrinter,
    'graphviz.dot' => RubyProf::DotPrinter,
    'graph.html' => RubyProf::GraphHtmlPrinter,
    'callstack.html' => RubyProf::CallStackPrinter
  }.each do |file_name, klass|
    full_file_name = "#{REPORT_PATH}/#{file_name}"
    klass.new(result).print(File.open(full_file_name, 'w'))
    `#{OPEN_CMD} #{full_file_name}`
  end

  RubyProf::CallTreePrinter.new(result).print(path: REPORT_PATH, profile: 'profile')
  `qcachegrind report/profile.callgrind.out.*`
  `rm report/profile.callgrind.out.*`
end

def ruby_prof_alloc
  ruby_prof RubyProf::ALLOCATIONS
end

def ruby_prof_memory
  ruby_prof RubyProf::MEMORY
end

# do_work(limit: NO_LIMIT)
# do_work(limit: LIMIT)

# memory_profiler
# stackprof
# ruby_prof_alloc
ruby_prof_memory
