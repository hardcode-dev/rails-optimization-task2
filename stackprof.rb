require 'stackprof'
require 'json'
require_relative 'task-2.rb'

StackProf.run(mode: :object, out: 'stackprof_reports/stackprof.dump', raw: true) do
  work('data300_000.txt')
end

profile = StackProf.run(mode: :wall, raw: true) do
  work('data300_000.txt')
end

File.write('stackprof_reports/stackprof.json', JSON.generate(profile))