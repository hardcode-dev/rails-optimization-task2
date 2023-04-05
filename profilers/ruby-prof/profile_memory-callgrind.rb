# https://ruby-prof.github.io/#version-1.0 (ruby 2.4+)
# ruby-prof + patched-ruby + QCachegrind MEMORY profiling

require 'ruby-prof'
require_relative '../../task-2.rb'

# На этот раз профилируем не allocations, а объём памяти!
RubyProf.measure_mode = RubyProf::MEMORY

result = RubyProf.profile do
  work(
    file: ENV.fetch('DATA_FILE', "data/data_32_500.txt"),
    disable_gc: false
  )
end

printer = RubyProf::CallTreePrinter.new(result)
printer.print(path: 'reports/tmp/ruby-prof', profile: 'profile')
