require 'ruby-prof'
require_relative 'task-2.rb'

# На этот раз профилируем не allocations, а объём памяти!
RubyProf.measure_mode = RubyProf::MEMORY

result = RubyProf.profile do
  work('data_large.txt')
end

printer = RubyProf::CallTreePrinter.new(result)
printer.print(path: 'reports', profile: 'profile')

printer = RubyProf::GraphHtmlPrinter.new(result)
printer.print(File.open('reports/graph.html', 'w+'))