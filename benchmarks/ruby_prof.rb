# frozen_string_literal: true

require 'ruby-prof'
require_relative '../task-2'

FILE_MASK = '*.txt'

DEMO_DATA = Dir["benchmarks/demo_data/#{ENV['FILE'] || FILE_MASK}"].freeze

user_reports = ENV['REPORT'].to_s.split(',')
REPORTS = user_reports.size.positive? ? user_reports : %w[flat graph call_stack call_tree].freeze
REPORT_PATH = 'benchmarks/reports/ruby_prof'

RubyProf.measure_mode = RubyProf::ALLOCATIONS

def generate_report(result, file_name)
  REPORTS.each do |report|
    case report
    when 'flat'
      printer = RubyProf::FlatPrinter.new(result)
      save_report(printer, "#{REPORT_PATH}/#{report}_#{file_name}")
    when 'graph'
      printer = RubyProf::GraphHtmlPrinter.new(result)
      save_report(printer, "#{REPORT_PATH}/#{report}_#{file_name}.html")
    when 'call_stack'
      printer = RubyProf::CallStackPrinter.new(result)
      save_report(printer, "#{REPORT_PATH}/#{report}_#{file_name}.html")
    when 'call_tree'
      printer = RubyProf::CallTreePrinter.new(result)
      printer.print(path: REPORT_PATH, profile: 'callgrind')
    end
  end
end

def save_report(printer, file_name, profile = nil)
  printer.print(File.open(file_name, 'w+'))
end

DEMO_DATA.each do |file|
  result = RubyProf.profile do
    work(file)
  end
  generate_report(result, file.split('_').last)
end