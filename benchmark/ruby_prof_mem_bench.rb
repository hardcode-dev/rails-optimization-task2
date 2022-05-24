# https://ruby-prof.github.io/#version-1.0 (ruby 2.4+)
# ruby-prof + QCachegrind MEMORY profiling

require 'ruby-prof'
require_relative '../task-2.rb'

# На этот раз профилируем не allocations, а объём памяти!
RubyProf.measure_mode = RubyProf::MEMORY

# system('rm ruby_prof_reports/profile.callgrind.out.*')

result = RubyProf.profile do
  work('./benchmark/support/data_16k.txt', disable_gc: false)
end

printer = RubyProf::CallTreePrinter.new(result)
printer.print(path: 'ruby_prof_reports', profile: 'profile')

system('qcachegrind $(ls -Art ruby_prof_reports/profile.callgrind.out.* | tail -n1)')
