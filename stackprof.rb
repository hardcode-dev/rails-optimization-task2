require 'stackprof'
require 'json'
require_relative 'task-2.rb'

StackProf.run(mode: :object, out: 'stackprof_reports/stackprof.dump', raw: true) do
  work('data_40000.txt', disable_gc: true)
end

profile = StackProf.run(mode: :object, raw: true) do
  work('data_40000.txt', disable_gc: true)
end

File.write('stackprof_reports/stackprof.json', JSON.generate(profile))
