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
require_relative '../src/report'

# Note mode: :object
GC.disable
StackProf.run(mode: :object, out: '../reports/stackprof.dump', raw: true) do
  work('../data_16000.txt', disable_gc: false)
end
GC.enable
