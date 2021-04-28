# frozen_string_literal: true

class User
  attr_reader :key

  def initialize(line)
    line[/.*,([^,]+),([^,]+),\d+$/]
    @key = "#{$1} #{$2}".freeze

    @browsers = []
    @dates = []
    @count = 0
    @total_time = 0
    @longest_session = 0
    @ie_ever = false
    @always_chrome = nil
  end

  def add_session(browser, time, date)
    @count += 1
    add_browser browser
    add_time time
    add_date date
  end

  def add_time(time)
    @total_time += time
    @longest_session = time if time > @longest_session
  end

  def add_browser(browser)
    return if @browsers.include?(browser)

    @browsers.push browser
    @ie_ever ||= browser.match?(/INTERNET EXPLORER/)
    @always_chrome = (@always_chrome || @always_chrome.nil?) && browser.match?(/CHROME/)
  end

  def add_date(date)
    @dates.push(date) unless @dates.include?(date)
  end

  def stats
    @dates.sort!.reverse!
    @browsers.sort!

    {
      'sessionsCount' => @count,
      'totalTime' => "#{@total_time} min.",
      'longestSession' => "#{@longest_session} min.",
      'browsers' => @browsers.join(', '),
      'usedIE' => @ie_ever,
      'alwaysUsedChrome' => @always_chrome,
      'dates' => @dates
    }
  end
end