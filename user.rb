require 'date'

class User
  attr_reader :attributes
  attr_accessor :sessions

  def initialize(cols)
    @attributes = {
      'id' => cols[1],
      'first_name' => cols[2],
      'last_name' => cols[3],
      'age' => cols[4],
    }
    @sessions = []
  end

  def key
   "#{attributes['first_name']} #{attributes['last_name']}"
  end

  def total_sessions_time
    "#{sessions_time.sum} min."
  end

  def longest_session_time
    "#{sessions_time.max} min."
  end

  def browsers_string
    browsers.sort.join(', ')
  end

  def used_ie
    browsers.any? { |b| b =~ /INTERNET EXPLORER/ }
  end

  def always_chrome
    browsers.all? { |b| b =~ /CHROME/ }
  end

  def session_dates
    sessions.map { |s| s['date'] }.sort.reverse
  end

  def to_s
    "\"#{key}\":\{\"sessionsCount\":#{sessions.count},\"totalTime\":\"#{total_sessions_time}\",\"longestSession\":\"#{longest_session_time}\",\"browsers\":\"#{browsers_string}\",\"usedIE\":#{used_ie},\"alwaysUsedChrome\":#{always_chrome},\"dates\":#{session_dates}\}"
  end

  private

  def browsers
    @browsers ||= sessions.map { |s| s['browser'].upcase }
  end

  def sessions_time
    @sessions_time ||= sessions.map { |s| s['time'].to_i }
  end
end
