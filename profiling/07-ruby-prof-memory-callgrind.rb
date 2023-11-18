# https://ruby-prof.github.io/#version-1.0 (ruby 2.4+)
# ruby-prof + patched-ruby + QCachegrind MEMORY profiling

require_relative 'setup'

# На этот раз профилируем не allocations, а объём памяти!
RubyProf.measure_mode = RubyProf::MEMORY

result = RubyProf.profile { work(Setup::FILE_PATH, disable_gc: true) }


# printer.print(path: 'ruby_prof_reports', profile: 'profile')

printer = RubyProf::CallTreePrinter.new(result)
# file_path = File.join(Setup::REPORTS_PATH, 'flat.txt')
# file = File.open(file_path, 'w+')
# printer.print(file)
printer.print(path: Setup::REPORTS_PATH, profile: 'profile')
