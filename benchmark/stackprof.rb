require 'stackprof'
require_relative '../task-2.rb'

StackProf.run(mode: :object, out: 'reports/stackprof.dump', raw: true) do
  work('data_100000.txt', disable_gc: false)
end
