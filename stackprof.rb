# Stackprof report
# ruby 16-stackprof.rb
# cd stackprof_reports
# stackprof stackprof.dump
# stackprof stackprof.dump --method Object#work

require 'stackprof'
require_relative 'task-2-with-argument.rb'

`head -n #{16000} data_large.txt > data_small.txt`

StackProf.run(mode: :object, out: 'stackprof_reports/stackprof.dump', interval: 1000) do
  work("data_small.txt")
end
