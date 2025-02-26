require_relative './task-2'
require 'stackprof'

StackProf.run(mode: :wall, out: './stackprof.dump', interval: 1000) do
  work('/spec/fixtures/files/data_20000.txt', disable_gc: true)
end
