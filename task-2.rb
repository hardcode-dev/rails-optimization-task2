# Deoptimized version of homework task

require 'set'
require 'json'
# require 'pry'
require 'date'
# require 'minitest/autorun'

class Browser
  CHROME = 'CHROME'.freeze
  INTERNET_EXPLORER = 'INTERNET EXPLORER'.freeze

  class << self
    def all
      @all ||= []
    end

    def find_by(name)
      all.find { |b| b.name == name }
    end

    def find_or_initialize_by_name(name)
      find_by(name) || Browser.new(name: name)
    end

    def add(browser)
      @all << browser
    end
  end

  attr_reader :name

  def initialize(name:)
    upcased = name.upcase # will be cleared by GC
    @is_chrome = upcased.include?(CHROME)
    @is_ie = upcased.include?(INTERNET_EXPLORER)
    @name = upcased.to_sym
    self.class.find_by(@name) || self.class.add(self)
  end

  def ie?
    @is_ie
  end

  def chrome?
    @is_chrome
  end
end

class User
  attr_reader :attributes, :sessions

  def initialize(attributes:, sessions:)
    @attributes = attributes
    @sessions = sessions
  end
end

COMMA = ','.freeze
COMMA_WITH_SPACE = ', '.freeze
MIN_POSTFIX = ' min.'.freeze
SESSION_LINE_START = 'session'.freeze
USER_LINE_START = 'user'.freeze
MEMORY_COMMAND = 'ps -o rss= -p '.freeze
PROCESS = Process.pid.freeze

def parse_user(user)
  fields = user.split(COMMA)
  parsed_result = {
    id: fields[1].to_i,
    first_name: fields[2],
    last_name: fields[3],
    age: fields[4],
  }
end

def parse_session(session)
  fields = session.split(COMMA)
  parsed_result = {
    user_id: fields[1].to_i,
    session_id: fields[2].to_i,
    browser: fields[3],
    time: fields[4].to_i,
    date: fields[5],
  }
end

def parse_user_line!(line, report, users_map)
  attributes = parse_user(line)
  id, first_name, last_name = attributes.fetch_values(*%i[id first_name last_name])
  full_name = :"#{first_name} #{last_name}"
  users_map[id] = full_name

  report[:totalUsers] += 1
  report[:usersStats][full_name] = {
    sessionsCount: 0,
    totalTime: 0,
    longestSession: 0,
    browsers: [],
    usedIE: false,
    alwaysUsedChrome: false, # to be defined on finish
    dates: [] # to be sorted on finish
  }
end

def parse_session_line!(line, report, users_map)
  attributes = parse_session(line)
  user_id, browser, time, date = attributes.fetch_values(*%i[user_id browser time date])

  browser = Browser.find_or_initialize_by_name(browser)
  # global info
  report[:totalSessions] += 1
  # report[:allBrowsers] << browser

  # user info
  report[:usersStats][users_map[user_id]][:sessionsCount] += 1
  report[:usersStats][users_map[user_id]][:totalTime] += time.to_i
  if time.to_i > report[:usersStats][users_map[user_id]][:longestSession]
    report[:usersStats][users_map[user_id]][:longestSession] = time.to_i
  end
  report[:usersStats][users_map[user_id]][:browsers] << browser
  # unique_browsers << browser
  report[:usersStats][users_map[user_id]][:usedIE] = true if browser.ie?
  report[:usersStats][users_map[user_id]][:dates] << date.chomp.to_sym
end

def work(file_path = 'small.txt', disable_gc: false, force_gc: true)
  time_point = Time.now
  GC.disable if disable_gc

  users = {}

  result_json = {
    totalUsers: 0,
    uniqueBrowsersCount: 0, # to be defined on finish
    totalSessions: 0,
    allBrowsers: [],
    usersStats: {}
  }

  unique_browsers = Set.new
  users_map = {}

  File.foreach(file_path) do |line|
    if line.start_with?(USER_LINE_START)
      parse_user_line!(line, result_json, users_map)
      GC.start
    end
    parse_session_line!(line, result_json, users_map) if line.start_with?(SESSION_LINE_START)
  end

  # result_json[:allBrowsers] = result_json[:allBrowsers].map(&:name).sort.join(COMMA)
  result_json[:allBrowsers] = Browser.all.map(&:name).sort.join(COMMA)
  result_json[:usersStats].keys.each do |name|
    result_json[:usersStats][name][:alwaysUsedChrome] = result_json[:usersStats][name][:browsers].all?(&:chrome?)
    result_json[:usersStats][name][:browsers] = result_json[:usersStats][name][:browsers].map(&:name).sort.join(COMMA_WITH_SPACE)
    result_json[:usersStats][name][:dates] = result_json[:usersStats][name][:dates].sort.reverse
    result_json[:usersStats][name][:longestSession] = "#{result_json[:usersStats][name][:longestSession]}#{MIN_POSTFIX}"
    result_json[:usersStats][name][:totalTime] = "#{result_json[:usersStats][name][:totalTime]}#{MIN_POSTFIX}"
  end
  result_json[:uniqueBrowsersCount] = Browser.all.count

  report = result_json
  File.write('result.json', "#{report.to_json}\n")

  puts "MEMORY USAGE: %d MB" % (memory_usage)
  puts "It took #{Time.now - time_point} seconds"
end

def memory_usage
  `#{MEMORY_COMMAND}#{PROCESS}`.to_i / 1024
end
