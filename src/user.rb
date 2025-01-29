# frozen_string_literal: true

class User
  attr_reader :key

  def initialize(key)
    @key = key

    @sessions_count = 0
    @total_time = 0
    @longest_session = 0
    @browsers = []
    @used_ie = false
    @always_used_chrome = false
    @dates = []
  end

  def calculate_parameters(sessions)
    return unless sessions

    used_chrome = false
    used_another_browser = false
    sessions.each do |session|
      @sessions_count += 1

      time = session[:time]
      @total_time += time
      @longest_session = time if @longest_session < time

      browser = session[:browser]
      @browsers.push(browser)
      @used_ie = true if !@used_ie && browser =~ /INTERNET EXPLORER/
      if browser =~ /CHROME/
        used_chrome = true
      else
        used_another_browser = true
      end

      @dates.push(session[:date])
    end
    @always_used_chrome = used_chrome && !used_another_browser
  end

  def stats
    {
      sessionsCount: @sessions_count,
      totalTime: "#{@total_time} min.",
      longestSession: "#{@longest_session} min.",
      browsers: @browsers.sort!.join(', '),
      usedIE: @used_ie,
      alwaysUsedChrome: @always_used_chrome,
      dates: @dates.sort!.reverse!
    }
  end
end
