# Stackprof ObjectAllocations and Flamegraph
#
# Text:
# stackprof stackprof.dump
# stackprof stackprof.dump --method Object#work
#
# Graphviz:
# stackprof --graphviz profiling/stackprof_reports/stackprof.dump > graphviz.dot
# dot -Tpng graphviz.dot > graphviz.png
# imgcat graphviz.png

require_relative '../spec/spec_helper'
require 'stackprof'

size = 100_000
file_path = fixture(size)
ensure_test_data_exists(size)

# Note mode: :object
StackProf.run(mode: :object, out: File.expand_path('profiling/stackprof_reports/stackprof.dump'), raw: true) do
  work(file_path, disable_gc: false)
end
