require_relative '../task-2'
require 'stackprof'

StackProf.run(mode: :object, out: 'profiling/stackprof_object.dump') do
  Parser.new.work('../500000.txt')
end
