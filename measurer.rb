require_relative 'main'

class Measurer
  MEMORY_USAGE_LIMIT_MB = 70
  CHECK_USAGE_INTERVAL_SEC = 1

  def initialize(count_lines: nil)
    @count_lines = count_lines
  end

  def call = [memory_measurer_thread, work_thread].map(&:join)

  private

  attr_reader :count_lines

  def work_thread = @work_thread ||= Thread.new { Main.new(options: { count_lines: }).call }

  def memory_measurer_thread = Thread.new do
    while work_thread.alive?
      sleep CHECK_USAGE_INTERVAL_SEC
      current_memory_usage_mb = `ps -o rss= -p #{Process.pid}`.to_i / 1024
      if current_memory_usage_mb > MEMORY_USAGE_LIMIT_MB
        puts "MEMORY USAGE: #{current_memory_usage_mb} MB, BUT LIMIT: #{MEMORY_USAGE_LIMIT_MB}. TERMINATING."
        exit
      else
        puts "MEMORY USAGE: #{current_memory_usage_mb} MB"
      end
    end
  end
end

# Zero iteration:
# 15_000 lines: 57 MB (optimizing users and sessions collecting)
# First iteration:
# full: 38 MB (10 sec) (optimizing file stream processing)