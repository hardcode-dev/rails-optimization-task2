require 'ruby-prof'
require_relative 'task-2'

profile = RubyProf::Profile.new(measure_mode: RubyProf::MEMORY)

result = profile.profile do
  # work('data10000.txt', disable_gc: false)
  work('data_large.txt', disable_gc: false)
end

printer = RubyProf::CallTreePrinter.new(result)
printer.print(path: 'ruby_prof_reports', profile: 'profile')
