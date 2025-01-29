require 'benchmark'
require_relative 'task-2.rb'

def benchmarked_work
  i = 512

  while File.exists?("data/data_#{i}.txt")
    GC.start(full_mark: true, immediate_sweep: true)
    filename = "data/data_#{i}.txt"

    puts "---------------------"
    time = Benchmark.realtime do
      work(filename)
    end

    puts "Finished in #{time.round(5)}"

    i = i * 2
  end
end

benchmarked_work
