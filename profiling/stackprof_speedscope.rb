# Stackprof report -> flamegraph in speedscope
# ruby 17-stackprof-speedscope.rb
require 'json'
require 'stackprof'
require_relative '../task-2'

profile = StackProf.run(mode: :object, raw: true) do
  work('../data/data64000.txt')
end

File.write('stackprof_reports/stackprof.json', JSON.generate(profile))
