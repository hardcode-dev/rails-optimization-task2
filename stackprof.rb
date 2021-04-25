require 'stackprof'
require_relative 'task-2'

StackProf.run(mode: :object, out: 'reports/stackprof.dump', raw: true) do
  work('samples/10000.txt')
end
