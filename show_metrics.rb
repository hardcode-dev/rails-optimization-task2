require 'benchmark'
require_relative 'task-2'

def print_memory_usage
  str = 'Использовано памяти: '
  str << "%d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
  puts str
end

def report_gc_delta(before, after)
  puts "GCs Count (counted on delta): #{after[:count] - before[:count]}"
end

def print_object_space_count_objects(short: true)
  str = "Всего объектов: "
  if short
    str << ObjectSpace.each_object.count.to_s
  else
    str << "\n"
    ObjectSpace.count_objects.each { |k, v| str << "#{k.to_s.gsub('T_', '')}: #{v}\n" }
  end
  puts str
end

def print_gc_stats(message, stats: GC.stat, short: true)
  stats = stats.slice(:total_allocated_objects, :malloc_increase_bytes) if short
  puts message
  stats.each { |k, v| puts "#{k}: #{v}" }
end


def benchmark_work(data_file, short: true)
  puts "### START ###\n\n"

  time = Benchmark.realtime do
    puts "-- До запуска -- \n\n"
    print_memory_usage
    print_object_space_count_objects(short: short)
    print_gc_stats('Статистика GC:')

    work(file_path: data_file)

    puts "\n--После запуска--\n\n"
    print_memory_usage
    print_object_space_count_objects(short: short)
    print_gc_stats('Статистика GC:', short: short)
  end

  puts "\nFinish in #{time.round(2)}\n"
  puts "### END ### \n\n"
end

benchmark_work('data_samples/data_large.txt', short: true)
