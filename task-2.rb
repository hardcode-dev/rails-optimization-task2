COMMA = ','.freeze
USER_ID = 'user_id'.freeze
SESSION_ID = 'session_id'.freeze
BROWSER = 'browser'.freeze
TIME = 'time'.freeze
DATE = 'date'.freeze

User = Struct.new(
  :id,
  :first_name,
  :last_name,
  keyword_init: true
)

def parse_user(user)
  User.new(
    id: user[1],
    first_name: user[2],
    last_name: user[3]
  )
end

def parse_session(session)
  {
    USER_ID => session[1],
    SESSION_ID => session[2],
    BROWSER => session[3],
    TIME => session[4],
    DATE => session[5]
  }
end

def convert_user_data(sessions, last_user: false)
  full_name = "#{@current_user.first_name} #{@current_user.last_name}"
  browsers = sessions.map do |b|
    @all_browsers << b[3].upcase
    b[3].upcase
  end
  @all_browsers.uniq!
  result = "\"#{full_name}\":{\"sessionsCount\":#{sessions.count}," \
          "\"totalTime\":\"#{sessions.map { |b| b[4].to_i }.sum} min.\"," \
          "\"longestSession\":\"#{sessions.map { |b| b[4].to_i }.max} min.\"," \
          "\"browsers\":\"#{browsers.sort.join(', ')}\"," \
          "\"usedIE\":#{sessions.any? { |b| b[3].upcase.match?(/INTERNET EXPLORER/) }}," \
          "\"alwaysUsedChrome\":#{sessions.all? { |b| b[3].upcase.match?(/CHROME/) }}," \
          "\"dates\":#{sessions.map { |b| b[5] }.sort.reverse}},"
  result.chomp!(',') if last_user
  result
end

def work(filename)
  result = File.open('result.json', 'w')
  result << '{"usersStats":{'

  total_users = 0
  total_sessions = 0
  @all_browsers = []
  user_sessions = []

  File.foreach(filename) do |line|
    line = line.strip
    cols = line.split(COMMA)

    if cols[0].to_sym == :user
      result << convert_user_data(user_sessions) if @current_user && @current_user.id != cols[1]

      @current_user = parse_user(cols)
      total_users += 1
      user_sessions = []
    elsif cols[0].to_sym == :session
      user_sessions << cols
      total_sessions += 1
    end
  end

  result << convert_user_data(user_sessions, last_user: true)
  uniq_browser = @all_browsers.sort
  result << "},\"totalUsers\":#{total_users},\"uniqueBrowsersCount\":#{uniq_browser.size},\"totalSessions\":#{total_sessions},\"allBrowsers\":\"#{uniq_browser.join(',')}\"}"
  result.close

  puts 'MEMORY USAGE: %d MB' % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
end
