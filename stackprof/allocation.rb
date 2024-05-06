require_relative '../task-2'

require 'stackprof'

StackProf.run(mode: :object, out: "tmp/stackprof/allocation_#{Time.now.to_i}.dump", raw: true) do
  GC.disable
  work
end
