# Deoptimized version of homework task
# frozen_string_literal: true
#
require 'json'
require 'date'
require 'get_process_mem'

def print_usage(description)
  mb = GetProcessMem.new.mb
  puts "#{ description } - MEMORY USAGE(MB): #{ mb.round }"
end

SEPARATOR = ','
SPACE = ' '
CACHED_DATES = {}

# row types
SESSION = 'session'
USER = 'user'

DATE_FORMAT = '%Y-%m-%d'

MIN_POSTFIX = ' min.'

BROWSER_SEPARATOR = ', '

# Report fields
USER_STATS = 'usersStats'
SESSION_COUNT = 'sessionsCount'
TOTAL_TIME = 'totalTime'
LONGEST_SESSION = 'longestSession'
BROWSERS = 'browsers'
USED_IE = 'usedIE'
ALWAYS_USED_CHROME = 'alwaysUsedChrome'
DATES = 'dates'

CHROME = 'CHROME'
INTERNET_EXPLORER = 'INTERNET EXPLORER'

def parse_date(date)
  CACHED_DATES[date] ||= Date.strptime(date, DATE_FORMAT).iso8601
end

class Session
  attr_reader :user_id, :session_id, :browser, :time, :date

  def initialize(user_id, session_id, browser, time, date)
    @user_id = user_id.to_i
    @session_id = session_id.to_i
    @browser = browser.upcase
    @time = time.to_i
    @date = parse_date(date)
  end

  def self.from_string(string)
    new(*string.split(SEPARATOR)[1..5])
  end
end

class User
  attr_reader :id, :first_name, :last_name

  def self.from_string(string)
    new(*string.split(SEPARATOR)[1..3])
  end

  def initialize(id, first_name, last_name)
    @id = id.to_i
    @first_name = first_name
    @last_name = last_name

    @statistic = {
      SESSION_COUNT => 0,
      TOTAL_TIME => 0,
      LONGEST_SESSION => 0,
      BROWSERS => {},
      DATES => []
    }
  end

  def update_session_statistic(session)
    @statistic[SESSION_COUNT] += 1
    @statistic[TOTAL_TIME] += session.time
    @statistic[LONGEST_SESSION] = session.time if session.time > @statistic[LONGEST_SESSION]
    @statistic[BROWSERS][session.browser] ||= 0 and @statistic[BROWSERS][session.browser] += 1
    @statistic[DATES] << session.date
    @statistic[USED_IE] ||= true if session.browser.start_with? INTERNET_EXPLORER
    @statistic[ALWAYS_USED_CHROME] ||= false unless session.browser.start_with? CHROME
  end

  def to_json(*_args)
    { "#{first_name}#{SPACE}#{last_name}" => statistic }.to_json(*_args)
  end

  def statistic
    {
      SESSION_COUNT => @statistic[SESSION_COUNT],
      TOTAL_TIME => "#{@statistic[TOTAL_TIME]}#{MIN_POSTFIX}",
      LONGEST_SESSION => "#{@statistic[LONGEST_SESSION]}#{MIN_POSTFIX}",
      BROWSERS => @statistic[BROWSERS].flat_map { |k, v| v.times.map { |_| k } }.sort.join(BROWSER_SEPARATOR),
      USED_IE => !!@statistic[USED_IE],
      ALWAYS_USED_CHROME => @statistic[ALWAYS_USED_CHROME],
      DATES => @statistic[DATES].sort.reverse
    }
  end
end

class ParserOptimized
  class << self
    def work(filename = 'data_large.txt')
      unique_browsers = {}

      report = {
        totalUsers: 0,
        uniqueBrowsersCount: 0,
        totalSessions: 0,
        allBrowsers: [],
      }

      result_file = File.open('result.json', 'w')
      result_file.write "{\"#{USER_STATS}\":{"

      file = File.new filename
      user = nil
      loop do
        line = file.gets
        flush_user_stat_to_file(result_file, user) && break unless line

        if line.start_with? USER
          if user
            flush_user_stat_to_file(result_file, user)
            result_file.write(',')
          end
          user = User.from_string(line)
          report[:totalUsers] += 1
        else
          session = Session.from_string(line)

          raise "different session id #{session.user_id} and user id #{user.id}" unless session.user_id == user.id

          unique_browsers[session.browser] = nil
          report[:totalSessions] += 1
          user.update_session_statistic session
        end
      end

      result_file.write('},')

      unique_browsers = unique_browsers.keys
      report[:uniqueBrowsersCount] = unique_browsers.length
      report[:allBrowsers] = unique_browsers.sort.join(SEPARATOR)

      json_data = report.to_json
      result_file.write(json_data[1..])

      result_file.close

      print_usage 'TOTAL'
    end

    private

    def flush_user_stat_to_file(file, user)
      json = user.to_json
      file.write(json[1..(json.length - 2)])
    end
  end
end
