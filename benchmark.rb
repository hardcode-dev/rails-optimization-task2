require_relative 'task-2'

def print_usage
  puts format('MEMORY USAGE: %d MB', (`ps -o rss= -p #{Process.pid}`.to_i / 1024))
end

print_usage
work('samples/10000.txt')
print_usage
