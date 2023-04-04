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
require_relative '../../task-2.rb'

out = "reports/tmp/stackprof/report.dump"

StackProf.run(mode: :object, out: out, raw: true) do
  work(
    file: ENV.fetch('DATA_FILE', "data/data_32_500.txt"),
    disable_gc: false
  )
end

profile = StackProf.run(mode: :object, raw: true) do
  work(
    file: ENV.fetch('DATA_FILE', "data/data_32_500.txt"),
    disable_gc: false
  )
end

File.write('reports/tmp/stackprof/flamegraph.json', JSON.generate(profile))
