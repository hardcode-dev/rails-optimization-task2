# Deoptimized version of homework task
require 'ruby-prof'
require 'stackprof'
require_relative 'main'


# RubyProf.measure_mode = RubyProf::MEMORY

# result = RubyProf.profile do
#   work('data_large.txt')
# end

# printer = RubyProf::CallTreePrinter.new(result)
# printer.print(path: 'reports',profile: 'profile')

work('data_large.txt')

# work('data300000.txt')
