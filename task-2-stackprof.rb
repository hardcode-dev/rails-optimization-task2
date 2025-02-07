# head -n <N lines> data_large.txt > data_prof.txt
# ruby task-2-stackprof.rb
# stackprof stackprof_reports/stackprof.dump

require 'stackprof'
require_relative 'task-2'

# Note mode: :object
StackProf.run(mode: :object, out: 'stackprof_reports/stackprof.dump', raw: true) do
  work(file_name: 'data_prof.txt')
end