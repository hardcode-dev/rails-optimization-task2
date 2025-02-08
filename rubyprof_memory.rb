require 'ruby-prof'
require_relative 'work'

profile = RubyProf::Profile.new(measure_mode: RubyProf::MEMORY)

result = profile.profile do
  work("data/data#{ENV['SIZE']}.txt", disable_gc: ENV['GB'] || false)
end

printer = RubyProf::FlatPrinter.new(result)
printer.print(File.open('ruby_prof_reports/flat_memory.txt', 'w+'))

printer = RubyProf::GraphHtmlPrinter.new(result)
printer.print(File.open('ruby_prof_reports/graph_memory.html', 'w+'))

printer = RubyProf::CallStackPrinter.new(result)
printer.print(File.open('ruby_prof_reports/callstack_memory.html', 'w+'))

printer = RubyProf::CallTreePrinter.new(result)
printer.print(path: 'ruby_prof_reports', profile: 'profile')