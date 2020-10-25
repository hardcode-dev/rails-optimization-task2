# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'

require_relative 'unit-test'
require_relative 'user'
require_relative 'slow_report_builder'

SlowReportBuilder.new.call('data_600.txt', 'full_report.json')
