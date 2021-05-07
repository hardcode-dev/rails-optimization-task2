def print_memory_usage
  memory_before = `ps -o rss= -p #{Process.pid}`.to_i
  yield
  memory_after = `ps -o rss= -p #{Process.pid}`.to_i

  puts "Memory before: #{(memory_before / 1024.0).round(2)} MB"
  puts "Memory after: #{(memory_after / 1024.0).round(2)} MB"
  puts "Memory real: #{((memory_after - memory_before) / 1024.0).round(2)} MB"
end

def print_time_spent(&block)
  time = Benchmark.realtime(&block)

  puts "Time: #{time.round(2)}"
end
