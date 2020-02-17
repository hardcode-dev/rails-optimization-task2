# frozen_string_literal: true

require 'set'
require 'oj'


class User
  attr_accessor :name, :sessions, :durations, :browsers, :used_ie, :used_not_only_chrome, :dates
  def initialize(name)
    @name = name
    @sessions = 0
    @durations = []
    @browsers = []
    @used_ie = false
    @used_not_only_chrome = false
    @dates = []
  end
end

class ReportBuilder
  def initialize(file)
    @file = file
    @users = 0
    @sessions = 0
    @all_browsers = []
    @all_browsers = SortedSet.new

    @result = File.open('result.json', 'w')
  end

  def stream_processing
    @result.write('{"usersStats":{')
    File.open(@file).each { |line| parse_data(line) }
    write_previous_user(true)
    @result.write("},\"totalUsers\":#{@users},")
    @result.write("\"uniqueBrowsersCount\":#{@all_browsers.count},")
    @result.write("\"totalSessions\":#{@sessions},")
    @result.write("\"allBrowsers\":\"#{@all_browsers.to_a.join(',')}\"}")

    @result.close

    `ps -o rss= -p #{Process.pid}`.to_i / 1024
  end

  private

  def parse_data(line)
    cols = line.chomp!.split(',')
    if cols[0] == 'user'
      @users += 1
      write_previous_user
      name = "#{cols[2]} #{cols[3]}"
      @user = User.new(name)
    else
      @sessions += 1
      @user.sessions += 1

      browser = cols[3].upcase!
      @user.browsers << browser
      @all_browsers.add browser
      @user.used_ie = true if browser.start_with?('INTERNET EXPLORER')
      @user.used_not_only_chrome ||= true unless browser.start_with?('CHROME')

      @user.durations << cols[4].to_i

      @user.dates << cols[5]
    end
  end

  def write_previous_user(last_user=false)
    return unless @user

    user_report = Hash.new
    user_report['sessionsCount']    = @user.dates.count
    user_report['totalTime']        = "#{@user.durations.reduce(:+)} min."
    user_report['longestSession']   = "#{@user.durations.max} min."
    user_report['browsers']         = @user.browsers.sort!.join(', ')
    user_report['alwaysUsedChrome'] = !@user.used_not_only_chrome
    user_report['usedIE']           = @user.used_ie
    user_report['dates']            = @user.dates.sort!.reverse!

    result = Oj.dump(user_report, mode: :compat)
    @result.write(+ '"' << @user.name << '":' << result)
    @result.write(',') unless last_user
  end
end

def work(file)
  ReportBuilder.new(file).stream_processing
end