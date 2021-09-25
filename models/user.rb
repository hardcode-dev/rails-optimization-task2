# frozen_string_literal: true

class User
  CHROME = 'CHROME'
  INTERNET_EXPLORER = 'INTERNET EXPLORER'
  B_SEPARATOR = ', '

  attr_reader :id, :first_name, :last_name, :stats

  def initialize(id, first_name, last_name)
    @id = id.to_i
    @first_name = first_name
    @last_name = last_name
    @stats = init_stats
  end

  def key
    @key ||= "#{first_name} #{last_name}"
  end

  def init_stats
    {
      sessionsCount: 0,
      totalTime: 0,
      longestSession: 0,
      browsers: {},
      usedIE: false,
      alwaysUsedChrome: true,
      dates: []
    }
  end

  def update_stats(session)
    increase_session_count
    collect_dates(session)
    calc_total_time(session)
    calc_longest_session(session)
    collect_browsers(session)
    used_internet_explorer(session)
    always_used_chrome(session)
  end

  def increase_session_count
    stats[:sessionsCount] += 1
  end

  def collect_dates(session)
    stats[:dates] << session.date
  end

  def collect_browsers(session)
    stats[:browsers][session.browser] ||= 0
    stats[:browsers][session.browser] += 1
  end

  def calc_total_time(session)
    stats[:totalTime] += session.time
  end

  def calc_longest_session(session)
    stats[:longestSession] = session.time if session.time > stats[:longestSession]
  end

  def used_internet_explorer(session)
    stats[:usedIE] = true if session.browser.start_with?(INTERNET_EXPLORER)
  end

  def always_used_chrome(session)
    stats[:alwaysUsedChrome] = false unless session.browser.start_with?(CHROME)
  end

  def collect_stats
    {
      sessionsCount: stats[:sessionsCount],
      totalTime: "#{stats[:totalTime]} min.",
      longestSession: "#{stats[:longestSession]} min.",
      browsers: stats[:browsers].flat_map { |k, v| v > 1 ? Array.new(v, k) : k }.sort!.join(B_SEPARATOR),
      usedIE: stats[:usedIE],
      alwaysUsedChrome: stats[:alwaysUsedChrome],
      dates: stats[:dates].sort.reverse
    }
  end

  def to_json(*args)
    { key => collect_stats }.to_json(*args)
  end
end
