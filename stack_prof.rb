require_relative 'config/environment'

StackProf.run(mode: :object, out: 'profiler_reports/stack_report.dump', raw: true) do
  GenerateReport.new.work('spec/support/fixtures/data_16000.txt')
end
