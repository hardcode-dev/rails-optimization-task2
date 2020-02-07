# Stackprof ObjectAllocations and Flamegraph
#
# Text:
# stackprof stackprof.dump
# stackprof stackprof.dump --method Object#work
#
# Graphviz:
# stackprof --graphviz stackprof_reports/stackprof.dump > graphviz.dot
# dot -Tpng graphviz.dot > graphviz.png
# imgcat graphviz.png

require 'stackprof'
require_relative 'task-2'

# Note mode: :object
StackProf.run(mode: :object, out: 'stack_prof_reports/stackprof.dump', raw: true) do
  Report.new.call('data_small.txt',false)
end