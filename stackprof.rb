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
require_relative 'task-2.rb'

# Note mode: :object
StackProf.run(mode: :object, out: 'stackprof_reports/stackprof.dump', raw: true) do
  work('data.txt', disable_gc: false)
end

require 'json'

profile = StackProf.run(mode: :wall, raw: true) do
  work('data.txt', disable_gc: true)
end

File.write('stackprof_reports/stackprof.json', JSON.generate(profile))
