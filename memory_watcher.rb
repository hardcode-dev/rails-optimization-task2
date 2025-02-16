class MemoryWatcher
  def initialize(memory_limit_mb)
    @memory_limit_mb = memory_limit_mb
    @should_stop = false
  end

  def start
    @thread = Thread.new do
      until @should_stop
        current_memory = `ps -o rss= -p #{Process.pid}`.to_i / 1024
        puts "MEMORY USAGE: #{current_memory} MB"
        if current_memory > @memory_limit_mb
          puts "Memory limit exceeded: #{current_memory}MB > #{@memory_limit_mb}MB"
          puts "Killing process..."
          Process.kill('KILL', Process.pid)
        end
        sleep 1
      end
    end
  end

  def stop
    @should_stop = true
    @thread.join if @thread
  end
end
