require_relative '../task-2'
require 'stackprof'
require 'json'

profile = StackProf.run(mode: :object, raw: true) do
  Parser.new.work('../100000.txt')
end

File.write('profiling/stackprof_object.json', JSON.generate(profile))
