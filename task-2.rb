# Deoptimized version of homework task

require 'set'
require 'json'
# require 'pry'
require 'date'
# require 'minitest/autorun'

class User
  attr_reader :attributes, :sessions

  def initialize(attributes:, sessions:)
    @attributes = attributes
    @sessions = sessions
  end
end

def parse_user(user)
  fields = user.split(',')
  parsed_result = {
    'id' => fields[1],
    'first_name' => fields[2],
    'last_name' => fields[3],
    'age' => fields[4],
  }
end

def parse_session(session)
  fields = session.split(',')
  parsed_result = {
    'user_id' => fields[1],
    'session_id' => fields[2],
    'browser' => fields[3],
    'time' => fields[4],
    'date' => fields[5],
  }
end

def collect_stats_from_users(report, users_objects, &block)
  users_objects.each do |user|
    user_key = "#{user.attributes['first_name']}" + ' ' + "#{user.attributes['last_name']}"
    report['usersStats'][user_key] ||= {}
    report['usersStats'][user_key] = report['usersStats'][user_key].merge(block.call(user))
  end
end


def work(file_path = 'small.txt', disable_gc: false)
  GC.disable if disable_gc

  users = {}

  result_json = {
    totalUsers: 0,
    uniqueBrowsersCount: 0, # to be defined on finish
    totalSessions: 0,
    allBrowsers: Set.new,
    usersStats: {}
  }

  unique_browsers = Set.new
  full_names_by_id = {}

  File.foreach(file_path) do |line|
    if line.start_with?('user')
      attributes = parse_user(line)
      id, first_name, last_name = attributes.fetch_values(*%w[id first_name last_name])
      full_name = :"#{first_name} #{last_name}"
      full_names_by_id[id] = full_name

      result_json[:totalUsers] += 1
      result_json[:usersStats][full_name] = {
        sessionsCount: 0,
        totalTime: 0,
        longestSession: 0,
        browsers: [],
        usedIE: false,
        alwaysUsedChrome: false, # to be defined on finish
        dates: [] # to be sorted on finish
      }
    end

    if line.start_with?('session')
      attributes = parse_session(line)
      user_id, browser, time, date = attributes.fetch_values(*%w[user_id browser time date])

      # global info
      result_json[:totalSessions] += 1
      result_json[:allBrowsers] << browser.upcase

      # user info
      result_json[:usersStats][full_names_by_id[user_id]][:sessionsCount] += 1
      result_json[:usersStats][full_names_by_id[user_id]][:totalTime] += time.to_i
      if time.to_i > result_json[:usersStats][full_names_by_id[user_id]][:longestSession]
        result_json[:usersStats][full_names_by_id[user_id]][:longestSession] = time.to_i
      end
      result_json[:usersStats][full_names_by_id[user_id]][:browsers] << browser.upcase
      unique_browsers << browser.upcase
      result_json[:usersStats][full_names_by_id[user_id]][:usedIE] = true if browser.upcase.include?('INTERNET EXPLORER')
      result_json[:usersStats][full_names_by_id[user_id]][:dates] << date.chomp
    end
  end

  result_json[:allBrowsers] = result_json[:allBrowsers].sort.join(',')
  result_json[:usersStats].keys.each do |name|
    result_json[:usersStats][name][:alwaysUsedChrome] = result_json[:usersStats][name][:browsers].all? { |b| b.include?('CHROME') }
    result_json[:usersStats][name][:browsers] = result_json[:usersStats][name][:browsers].sort.join(', ')
    result_json[:usersStats][name][:dates] = result_json[:usersStats][name][:dates].sort.reverse
    result_json[:usersStats][name][:longestSession] = "#{result_json[:usersStats][name][:longestSession]} min."
    result_json[:usersStats][name][:totalTime] = "#{result_json[:usersStats][name][:totalTime]} min."
  end
  result_json[:uniqueBrowsersCount] = unique_browsers.count

  report = result_json
  File.write('result.json', "#{report.to_json}\n")
  puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
end
