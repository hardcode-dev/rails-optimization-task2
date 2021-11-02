require_relative 'config/environment'

report = MemoryProfiler.report do
  GenerateReport.new.work('spec/support/fixtures/data_64000.txt')
end
report.pretty_print(scale_bytes: true)
