# frozen_string_literal: true

require 'stackprof'
require_relative '../task_2'

StackProf.run(mode: :object, out: 'reports/stackprof.dump', raw: true) do
  work
end
