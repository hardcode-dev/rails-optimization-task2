# Stackprof report
# ruby profilers/06_stackprof.rb
# cd profilers/stackprof_reports/
# stackprof stackprof.dump
# stackprof stackprof.dump --method Object#work
require_relative '../config/environment'

GC.disable

StackProf.run(mode: :wall, out: 'profilers/stackprof_reports/stackprof.dump', interval: 1000) do
  Task.new(data_file_path: './spec/fixtures/data_100k.txt').work
end

result_file_path = 'data/result.json'
File.delete(result_file_path) if File.exist?(result_file_path)

# stackprof --graphviz profilers/stackprof_reports/stackprof.dump > bla.dot
# dot -Tpng bla.dot > bla.png
# open bla.png
