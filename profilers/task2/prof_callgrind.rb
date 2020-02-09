# На этот раз профилируем не allocations, а объём памяти!
require_relative 'helper'

RubyProf.measure_mode = RubyProf::MEMORY

result = RubyProf.profile do
  Optimization::TaskTwo.work("#{@root}data/dataN.txt", true)
end

printer = RubyProf::CallTreePrinter.new(result)
printer.print(path: 'ruby_prof_reports/task2', profile: 'profile')
