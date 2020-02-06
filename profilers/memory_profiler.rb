require "memory_profiler"

require_relative "../task-2"

file_name = ENV["FILE_NAME"] || "data.txt"
file_path = File.join(ENV["PWD"], "spec", "fixtures", "data", file_name)

report = MemoryProfiler.report do
  report = Report.new(file_path)
  report.work
end

reports_path = File.join(ENV["PWD"], "reports")
report_file_path = reports_path + "/#{file_name}"

report.pretty_print(to_file: report_file_path, scale_bytes: true)
