require_relative 'task-2'
require 'stackprof'

StackProf.run(mode: :object, out: 'ruby_prof_reports/stackprof.dump', row: true) do
  work('./spec/fixtures/files/data_20000.txt', true)
end
