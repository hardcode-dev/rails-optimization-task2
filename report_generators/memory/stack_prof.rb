# frozen_string_literal: true

require 'stackprof'
require_relative '../../task-2'

StackProf.run(mode: :object, out: 'reports/stackprof_reports/stackprof.dump', raw: true) do
  work('data/data_10000.txt', disable_gc: false)
end
