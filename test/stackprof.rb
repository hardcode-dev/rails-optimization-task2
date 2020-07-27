require 'stackprof'
require_relative '../task-2.rb'
file_path = "#{__dir__}/../data/data1.txt"
report_path = "#{__dir__}/../tmp/stackprof.dump"
flamegraph_path = "#{__dir__}/../tmp/flamegraph"

GC.disable

StackProf.run(mode: :object, out: report_path, raw: true) do
  work(file_path)
end

system "stackprof --flamegraph #{report_path} > #{flamegraph_path}"

