class GlobalReport
  attr_reader :unique_browsers, :total_sessions, :total_time

  def initialize
    @unique_browsers = Set.new()
    @total_sessions = 0
    @total_time = 0
  end

  def process(fields)
    @unique_browsers << fields[3]

    @total_sessions += 1
    @total_time += fields[4].to_i
  end
end
