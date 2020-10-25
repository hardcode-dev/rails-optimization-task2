# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'

# require_relative 'unit-test'

require_relative 'user'
require_relative 'slow_report_builder'
require_relative 'fast_report_builder'

# SlowReportBuilder.new.call('data_600.txt', 'slow_report.json')
FastReportBuilder.new.call('data_600.txt', 'fast_report.json')
