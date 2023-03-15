require 'ruby-prof'
require_relative '../task-2.rb'

RubyProf.measure_mode = RubyProf::ALLOCATIONS

result = RubyProf.profile do
  work(file_path: 'test_data/data5000.txt')
end

printer = RubyProf::MultiPrinter.new(result)
printer.print(path: 'tmp/', profile: "rp_alloc_#{Time.now}")

File.open("tmp/rp_alloc_callstack_#{Time.now}.html", 'w') do |f|
  RubyProf::CallStackPrinter.new(result).print(f)
end


