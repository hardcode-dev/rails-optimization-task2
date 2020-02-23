require_relative '../lib/task-2'

class TestMemoryUsage
  def run
    work_thread = Thread.new do
      work(data_path('data_large.txt'))
    end
    loop do
      sleep(0.5)
      usage = check_memory_usage
      puts "#{usage}Mb"
      if usage > 70
        puts 'Memory usage got higher the limit'
        Thread.exit
      end
      break if !work_thread.status
    end
    work_thread.join
  end

  def check_memory_usage
    (`ps -o rss= -p #{Process.pid}`.to_i / 1024.0).round(2)
  end
end

TestMemoryUsage.new.run

