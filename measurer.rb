require_relative 'main'

class Measurer
  MEMORY_USAGE_LIMIT_MB = 70
  CHECK_USAGE_INTERVAL_SEC = 1

  def initialize(count_lines)
    @count_lines = count_lines
  end

  def call = [memory_measurer_thread, work_thread].map(&:join)

  private

  attr_reader :count_lines

  def work_thread = Thread.new { Main.new(options: { count_lines: }).call }

  def memory_measurer_thread = Thread.new do
    sleep CHECK_USAGE_INTERVAL_SEC
    current_memory_usage_mb = `ps -o rss= -p #{Process.pid}`.to_i / 1024
    if current_memory_usage_mb > MEMORY_USAGE_LIMIT_MB
      puts "MEMORY USAGE: #{current_memory_usage_mb} MB, BUT LIMIT: #{MEMORY_USAGE_LIMIT_MB}"
      exit
    end
  end
end

# Zero iteration:
# 15_000 lines: 103 MB
