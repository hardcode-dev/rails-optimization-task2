# TMPfrozen_string_literal: true
require_relative 'task-2'
require 'benchmark'
require 'memory_profiler'
require 'stackprof'
require 'ruby-prof'
data_size = 50000

StackProf.run(mode: :object, out: 'outputs/stackprof.dump', raw: true) do
    work("data/data#{data_size}.txt", true)
end

