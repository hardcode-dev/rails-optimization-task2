class GenerateUserStat
  class << self
    def call(user)
      new(user).template
    end
  end

  def initialize(user)
    @user = user
  end

  def template
    "\"#{@user.full_name}\":{\"sessionsCount\":#{sessions.count},\
    \"totalTime\":\"#{total_time} min.\",\
    \"longestSession\":\"#{longest_session} min.\",\
    \"browsers\":\"#{browsers}\",\
    \"usedIE\":#{used_ie},\
    \"alwaysUsedChrome\":#{always_used_chrome},\
    \"dates\":#{dates.to_json}}"
  end

  private

  def total_time
    user_sessions_times.sum
  end

  def longest_session
    user_sessions_times.max
  end

  def user_sessions_times
    sessions.map { |s| s.time.to_i }
  end

  def browsers
    user_browsers.sort.join(', ')
  end

  def used_ie
    user_browsers.any? { |b| b.start_with?('INTERNET EXPLORER') }
  end

  def always_used_chrome
    user_browsers.all? { |b| b.start_with?('CHROME') }
  end

  def user_browsers
    sessions.map { |s| s.browser }
  end

  def dates
    sessions.map { |s| s.date }.sort.reverse
  end

  def sessions
    @user.sessions
  end
end
