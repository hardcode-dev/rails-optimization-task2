require_relative 'task-2'.freeze
require 'ruby-prof'

def collect_prof_wall(file_name)
  RubyProf.measure_mode = RubyProf::WALL_TIME
  GC.disable
  result = RubyProf.profile do
    work(file_name)
  end
  GC.enable

  RubyProf::FlatPrinter
    .new(result).print(File.open('ruby_prof_reports/wall/flat_result', 'w+'))
  RubyProf::CallStackPrinter
    .new(result).print(File.open('ruby_prof_reports/wall/call_stack_result.html', 'w+'))
  RubyProf::GraphHtmlPrinter
    .new(result).print(File.open('ruby_prof_reports/wall/graph_result.html', 'w+'))
end

def collect_prof_allocations(file_name)
  RubyProf.measure_mode = RubyProf::ALLOCATIONS
  GC.disable
  result = RubyProf.profile do
    work(file_name)
  end
  GC.enable

  RubyProf::FlatPrinter
    .new(result).print(File.open('ruby_prof_reports/allocations/flat_result', 'w+'))
  RubyProf::CallStackPrinter
    .new(result).print(File.open('ruby_prof_reports/allocations/call_stack_result.html', 'w+'))
  RubyProf::GraphHtmlPrinter
    .new(result).print(File.open('ruby_prof_reports/allocations/graph_result.html', 'w+'))
end

def collect_prof_memory(file_name)
  RubyProf.measure_mode = RubyProf::MEMORY

  RubyProf::CallStackPrinter
    .new(RubyProf.profile { work(file_name) })
    .print(File.open('ruby_prof_reports/memory/call_stack_result.html', 'w+'))
end


collect_prof_wall('data_100K.txt')
collect_prof_allocations('data_100K.txt')
collect_prof_memory('data_100K.txt')
