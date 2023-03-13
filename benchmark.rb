# Запрос кол-ва используемой памяти (RSS) у ОС
# ruby 10-request-mem-consumption-from-os.rb
# FORCE_GC=1 ruby 10-request-mem-consumption-from-os.rb
require 'benchmark'
require_relative 'task-2'

time = Benchmark.realtime do
  GC.disable
  work(file: 'data10000.txt')
end

puts "Finish in #{time.round(2)}"