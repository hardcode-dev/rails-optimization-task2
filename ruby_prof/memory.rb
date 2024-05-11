require_relative '../task-2'

require 'ruby-prof'

RubyProf.measure_mode = RubyProf::MEMORY

result = RubyProf.profile do
  GC.disable
  work
end


printer = RubyProf::CallTreePrinter.new(result)
printer.print(path: 'tmp/ruby_prof', profile: 'profile')
