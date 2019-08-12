# RubyProf CallGrind report
# ruby profilers/05_ruby_prof_callgrind.rb

# brew install qcachegrind
# qcachegrind profilers/ruby_prof_reports/...

require_relative '../config/environment'

RubyProf.measure_mode = RubyProf::WALL_TIME

GC.disable

result = RubyProf.profile do
  Task.new(data_file_path: './spec/fixtures/data_100k.txt').work
end

printer = RubyProf::CallTreePrinter.new(result)
printer.print(path: 'profilers/ruby_prof_reports', profile: 'callgrind')

result_file_path = 'data/result.json'
File.delete(result_file_path) if File.exist?(result_file_path)
