# frozen_string_literal: true

class Task
  COMMA = ','.freeze
  COMMA_WITH_INDENT = ', '.freeze
  USER = 'user'.freeze
  SESSION = 'session'.freeze

  def initialize(result_file_path: nil, data_file_path: nil)
    @result_file_path = result_file_path || 'data/result.json'
    @data_file_path = data_file_path || 'data/data_large.txt'
  end

  def parse_user(fields)
    {
      id: fields[1],
      full_name: "#{fields[2]} #{fields[3]}"
    }
  end

  def parse_session(fields)
    {
      user_id: fields[1],
      session_id: fields[2],
      browser: fields[3].upcase,
      time: fields[4].to_i,
      date: fields[5].chomp,
    }
  end

  def collect_stats_from_user(report, user)
    user_key = user.attributes[:full_name]
    report[:usersStats][user_key] ||= {}
    report[:usersStats][user_key] = report[:usersStats][user_key].merge(yield(user))
  end

  def work
    uniqueBrowsers = Set.new
    report = { totalUsers: 0, uniqueBrowsersCount: 0, totalSessions: 0, allBrowsers: 0, usersStats: {} }

    File.foreach(data_file_path).with_index do |line, index|
      cols = line.split(COMMA)

      if cols[0] == USER
        prepare_stats(report, @user) unless  @user.nil?
        @user = User.new(attributes: parse_user(cols), sessions: [])
        report[:totalUsers] += 1
      end

      if cols[0] == SESSION
        session = parse_session(cols)
        uniqueBrowsers << session[:browser]
        @user.sessions << session
        report[:totalSessions] += 1
      end
    end

    prepare_stats(report, @user)

    report[:uniqueBrowsersCount] = uniqueBrowsers.count
    report[:allBrowsers] = uniqueBrowsers.sort.join(COMMA)

    File.write(result_file_path, "#{Oj.dump(report, mode: :compat)}\n")
    puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
  end

  private

  attr_reader :result_file_path, :data_file_path

  def prepare_stats(report, user_object)
    collect_stats_from_user(report, user_object) do |user|
      user_times = user.sessions.map { |session| session[:time] }
      user_browsers = user.sessions.map { |session| session[:browser] }
      user_dates = user.sessions.map { |session| session[:date] }

      {
        sessionsCount: user.sessions.count,
        totalTime:  "#{user_times.sum} min.",
        longestSession:  "#{user_times.max} min.",
        browsers: user_browsers.sort.join(COMMA_WITH_INDENT),
        usedIE: user_browsers.any? { |b| b.match? /INTERNET EXPLORER/ },
        alwaysUsedChrome: user_browsers.all? { |b| b.match? /CHROME/ },
        dates: user_dates.sort { |a, b| b <=> a }
      }
    end
  end
end
