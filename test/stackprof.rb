require 'stackprof'
require_relative '../task-2.rb'
file_path = "#{__dir__}/../data/data1.txt"
report_path = "#{__dir__}/../tmp/stackprof.dump"
stackprof_path = "#{__dir__}/../tmp/stackprof.json"

GC.disable

StackProf.run(mode: :object, out: report_path, raw: true) do
  work(file_path)
end

profile = StackProf.run(mode: :object, raw: true) do
  work(file_path)
end

File.write(stackprof_path, JSON.generate(profile))
