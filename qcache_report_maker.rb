# TMPfrozen_string_literal: true
require_relative 'task-2'
require 'benchmark'
require 'memory_profiler'
require 'stackprof'
require 'ruby-prof'
data_size = 50000

RubyProf.measure_mode = RubyProf::MEMORY
result = RubyProf.profile do
    work("data/data#{data_size}.txt", true)
end
printer = RubyProf::CallTreePrinter.new(result)

system("cd outputs && rm profile.callgrind.out*")
printer.print(path: 'outputs', profile: 'profile')
system("cd outputs && ls profile.callgrind.out* |  xargs qcachegrind")
 