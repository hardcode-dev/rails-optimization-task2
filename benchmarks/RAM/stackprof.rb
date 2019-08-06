require 'stackprof'
require_relative '../../task-2'

# Note mode: :object
StackProf.run(mode: :object, out: 'reports/stackprof.dump', raw: true) do
  work('../../data-500.txt')
end