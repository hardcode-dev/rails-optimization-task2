# https://ruby-prof.github.io/#version-1.0 (ruby 2.4+)
# ruby-prof + patched-ruby + QCachegrind MEMORY profiling

require 'ruby-prof'
require_relative '../src/report'

# На этот раз профилируем не allocations, а объём памяти!
RubyProf.measure_mode = RubyProf::MEMORY

GC.disable
result = RubyProf.profile do
  work('../data_64000.txt', disable_gc: false)
end
GC.enable

printer = RubyProf::CallTreePrinter.new(result)
printer.print(path: '../reports', profile: 'profile')
