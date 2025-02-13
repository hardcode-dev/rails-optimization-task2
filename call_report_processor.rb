# frozen_string_literal: true

require_relative 'report_processor'
#require_relative 'task-2'
require_relative 'profiling/profiling_helpers'


profile do
  ReportProcessor.new.call(input_file_name: 'data_large.txt', disable_gc: false)
end
