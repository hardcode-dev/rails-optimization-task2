require 'ruby-prof'
require_relative '../task-2.rb'

RubyProf.measure_mode = RubyProf::MEMORY

result = RubyProf.profile do
  work(file_path: 'test_data/data5000.txt')
end

printer = RubyProf::MultiPrinter.new(result)
printer.print(path: 'tmp/', profile: "rp_mem_#{Time.now}")

File.open("tmp/rp_mem_callstack_#{Time.now}.html", 'w') do |f|
  RubyProf::CallStackPrinter.new(result).print(f)
end
