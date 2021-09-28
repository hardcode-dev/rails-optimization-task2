# Stackprof ObjectAllocations and Flamegraph
#
# ruby optimization_tools/stackprof.rb
#
# Text:
# stackprof stackprof.dump
# stackprof stackprof.dump --method Object#work
#
# Graphviz:
# stackprof --graphviz optimization_tools/stackprof_reports/stackprof.dump > graphviz.dot
# dot -Tpng graphviz.dot > graphviz.png
# imgcat graphviz.png

require 'stackprof'
require_relative '../task-2.rb'

# Note mode: :object
StackProf.run(mode: :object, out: 'optimization_tools/stackprof_reports/stackprof.dump', raw: true) do
  work
end