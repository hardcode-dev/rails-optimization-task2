require 'ruby-prof'
require_relative 'work'

profile = RubyProf::Profile.new(measure_mode: RubyProf::ALLOCATIONS)

result = profile.profile do
  work("data/data#{ENV['SIZE']}.txt", disable_gc: ENV['GB'] || true)
end

printer = RubyProf::FlatPrinter.new(result)
printer.print(File.open('ruby_prof_reports/flat.txt', 'w+'))

printer = RubyProf::GraphHtmlPrinter.new(result)
printer.print(File.open('ruby_prof_reports/graph.html', 'w+'))

printer = RubyProf::CallStackPrinter.new(result)
printer.print(File.open('ruby_prof_reports/callstack.html', 'w+'))

printer = RubyProf::CallTreePrinter.new(result)
printer.print(path: 'ruby_prof_reports', profile: 'profile')