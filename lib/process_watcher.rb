# frozen_string_literal: true

class ProcessWatcher
  LOG_FILE_PATH = 'fixtures/log.txt'.freeze

  attr_reader :pid, :limit

  class LongMemoryUsageError < StandardError; end

  def initialize(pid:, limit:)
    @pid = pid
    @limit = limit
  end

  def watch
    File.write(LOG_FILE_PATH, '')
    f = File.open(LOG_FILE_PATH, 'w')
    thread = Thread.new(pid, f) do |process_pid, file|
      process = true
      
      while process
        memory = "%d" % (`ps -o rss= -p #{process_pid}`.to_i / 1024)
        f.write("#{Time.now}: #{memory} MB \n")
        raise LongMemoryUsageError, "usage memory to long #{memory}" if memory.to_i > limit
        # sleep(1)
      end
      rescue => e
        file.close
        raise e
    end
    thread.abort_on_exception = true
    [thread, f]
  end
end