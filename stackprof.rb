# Stackprof ObjectAllocations and Flamegraph
#
# Text:
# stackprof stackprof.dump
# stackprof stackprof.dump --method Object#work
#
# Graphviz:
# stackprof --graphviz stackprof_reports/stackprof.dump > stackprof_reports/graphviz.dot
# dot -Tpng stackprof_reports/graphviz.dot > stackprof_reports/graphviz.png
# imgcat stackprof_reports/graphviz.png

require 'stackprof'
require_relative 'task-2.rb'

# Note mode: :object
StackProf.run(mode: :object, out: 'stackprof_reports/stackprof.dump', raw: true) do
  work('data100000.txt', disable_gc: false)
end
