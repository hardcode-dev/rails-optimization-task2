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
# StackProf.run(mode: :object, out: '../reports/stackprof.dump', raw: true) do
#   work('../data_16000.txt')
# end

profile = StackProf.run(mode: :object, raw: true) do
  work('../data_16000.txt')
end
File.write('../reports/stackprof.json', JSON.generate(profile))
GC.enable
