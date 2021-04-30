require 'ruby-prof'
require_relative '../task-2'

RubyProf.measure_mode = RubyProf::ALLOCATIONS

RubyProf.start

ReportGenerate.new.work(ENV['FILENAME'] || 'data.txt')

result = RubyProf.stop

printer = RubyProf::GraphHtmlPrinter.new(result)
printer.print(File.open('./reports/result.html', 'w+'))