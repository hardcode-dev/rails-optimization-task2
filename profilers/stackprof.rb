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
require_relative '../parser'

# Note mode: :object
StackProf.run(mode: :object, out: 'profilers/stackprof_reports/stackprof.dump', raw: true) do
  Parser.new(disable_gc: false).work('data/data500_000.txt')
end
