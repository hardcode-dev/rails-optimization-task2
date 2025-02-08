# frozen_string_literal: true

class User
  attr_reader :browsers, :sessions_count, :first_name, :last_name

  def initialize(id, first_name, last_name, age)
    @id = id
    @first_name = first_name
    @last_name = last_name
    @age = age
    init_session_stats
  end

  def update_sessions_stats(user_id, _session_id, browser, time, date)
    return unless user_id == id

    time = time.to_i

    @total_time += time
    @longest_session = time if time > @longest_session
    @sessions_count += 1
    @browsers << browser.upcase
    @dates << date
  end

  def sessions_stats
    {
      sessionsCount: sessions_count,
      totalTime: "#{total_time} min.",
      longestSession: "#{longest_session} min.",
      browsers: browsers.sort.to_a.join(', '),
      usedIE: browsers.any? { |browser| browser.include?('INTERNET EXPLORER') },
      alwaysUsedChrome: browsers.all? { |browser| browser.include?('CHROME') },
      dates: @dates.sort.reverse
    }
  end

  private

  attr_reader :id, :age, :total_time, :longest_session

  def init_session_stats
    @total_time = 0
    @longest_session = 0
    @sessions_count = 0
    @browsers = []
    @dates = []
  end
end
