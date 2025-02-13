# frozen_string_literal: true

require 'benchmark'

def profile_memory
  yield
  memory_usage_after = `ps -o rss= -p #{Process.pid}`.to_i / 1024

  puts "Memory usage: #{memory_usage_after} MB"
end

def profile_time
  time = Benchmark.realtime do
    yield
  end

  puts "Time taken: #{time.round(2)} seconds"
end

def profile_gc
  GC.start
  before_allocated_objects = GC.stat[:total_allocated_objects]
  yield
  GC.start
  after_allocated_objects = GC.stat[:total_allocated_objects]

  puts "Total allocated objects during execution program: #{after_allocated_objects - before_allocated_objects}"
end

def profile
  profile_memory do
    profile_time do
      profile_gc do
        yield
      end
    end
  end
end
