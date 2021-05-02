#frozen_string_literal: true

require 'stackprof'
require_relative '../task-2'

# Note mode: :object
StackProf.run(mode: :object, out: 'benchmarks/reports/stackprof/stackprof.dump', raw: true) do
  work('benchmarks/demo_data/demo_data_10000.txt')
end
