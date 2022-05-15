require 'stackprof'
require_relative 'task-2.rb'

filename = "data/data_#{ENV['LINES']}.txt"

StackProf.run(mode: :object, out: 'stackprof_reports/stackprof.dump', raw: true) do
  work(filename)
end

# How to read:
# stackprof stackprof_reports/stackprof.dump
# stackprof stackprof_reports/stackprof.dump --method 'Object#work'
#
# Graphviz:
# stackprof --graphviz stackprof_reports/stackprof.dump > graphviz.dot
# dot -Tpng graphviz.dot > graphviz.png 
