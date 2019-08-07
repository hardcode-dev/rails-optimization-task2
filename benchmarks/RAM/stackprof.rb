require 'stackprof'
require_relative '../../task-2'

# Note mode: :object (Wall-time, CPU-time)
StackProf.run(mode: :object, out: 'reports/stackprof.dump', raw: true) do
  work('../../data-500.txt')
end