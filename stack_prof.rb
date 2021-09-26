require 'stackprof'
require_relative 'task-2.rb'

StackProf.run(mode: :object, out: 'stack_prof_reports/stackprof.dump', raw: true) do
  work('files/data_10_000.txt')
end