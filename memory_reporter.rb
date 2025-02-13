# frozen_string_literal: true

class MemoryReporter
  DEFAULT_LIMIT_MB = 700
  DEFAULT_INTERVAL = 1
  DEFAULT_LOG_FILE = 'reports/memory_usage.log'.freeze

  class MemoryUsageError < StandardError; end

  def initialize(limit_mb: DEFAULT_LIMIT_MB, log_file: DEFAULT_LOG_FILE)
    @limit_mb = limit_mb
    @log_file = log_file
  end

  def start
    @thread = Thread.new do
      loop do
        mem_usage_mb = current_memory_usage
        log_memory_usage(mem_usage_mb)
        raise MemoryUsageError, "Memory usage exceeded limit of #{@limit_mb} MB" if mem_usage_mb > @limit_mb
        sleep DEFAULT_INTERVAL
      rescue => e
        puts e.message
        Process.kill("KILL", Process.pid)
      end
    end
    @thread.abort_on_exception = true
  end

  private

  def current_memory_usage
    (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
  end

  def log_memory_usage(mem_usage_mb)
    File.open(@log_file, 'a') do |f|
      f.puts "[#{Time.now}] Memory usage: #{format('%.2f', mem_usage_mb)} MB"
    end
  end
end
