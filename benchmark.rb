require_relative 'task-2'

def memory_usage
  "%d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
end

def allocated_objects
  ObjectSpace.count_objects
end

work('data20000.txt')
puts memory_usage
puts allocated_objects
