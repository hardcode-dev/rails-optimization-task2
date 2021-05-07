# frozen_string_literal: true

require 'json'
require 'pry'
require 'date'
require 'set'
require 'minitest/autorun'
require 'benchmark'

require_relative 'memory_helper'

def parse_user(user)
  {
    'id' => user[1],
    'first_name' => user[2],
    'last_name' => user[3],
    'age' => user[4]
  }
end

def parse_session(session)
  {
    'user_id' => session[1],
    'session_id' => session[2],
    'browser' => session[3],
    'time' => session[4],
    'date' => session[5]
  }
end

def generate_user_report(user_id, users, report_file)
  user_fullname = "#{users[user_id]['first_name']} #{users[user_id]['last_name']}"

  report_file.puts(" \"#{user_fullname}\": {")

  normalized_sessions = []
  user_session_count = 0
  common_report = {}
  common_report[:user_session_seconds] = []
  common_report[:user_session_browsers] = []
  common_report[:reversed_session_dates] = []

  users[user_id][:sessions].each do |session|
    user_session_count += 1
    common_report[:user_session_seconds] << session['time'].to_i
    common_report[:user_session_browsers] << session['browser']
    normalized_sessions << session['browser']
    common_report[:reversed_session_dates] << session['date']
  end

  user_sessions_report =
    <<-JSON
        "sessionsCount": #{user_session_count},
        "totalTime": "#{common_report[:user_session_seconds].sum.to_s} min.",
        "longestSession": "#{common_report[:user_session_seconds].max.to_s} min.",
        "browsers": "#{normalized_sessions.sort!.join(', ')}",
        "usedIE": #{normalized_sessions.any? { |b| b.start_with?("INTERNET EXPLORER") }},
        "alwaysUsedChrome": #{normalized_sessions.all? { |b| b.start_with?("CHROME") }},
        "dates": #{common_report[:reversed_session_dates].sort!.reverse!}
      }
    JSON

  report_file.puts(user_sessions_report)

  users.delete(user_id)
end

def work(file: nil, disable_gc: false)
  GC.disable if disable_gc

  file ||= ARGV[0]
  report_file = File.new('result.json', 'w')

  users ||= {}
  session_count = 0
  users_count = 0
  unique_browser_set ||= SortedSet.new
  last_user_id = nil

  report_file.puts('{"usersStats": {')

  File.foreach(file).each do |line|
    cols = line.delete_suffix!("\n").split(',')

    if line.start_with?('user')
      report_file.puts(',') if users_count > 1

      user = parse_user(cols)
      users[cols[1]] = user
      users_count += 1

      generate_user_report(last_user_id, users, report_file) if last_user_id && last_user_id != cols[1]

      next
    end
    last_user_id = cols[1]

    session = parse_session(cols)
    session_count += 1
    unique_browser_set << session['browser'].upcase!

    users[cols[1]][:sessions] ||= []
    users[cols[1]][:sessions] << session
  end

  if users[last_user_id]
    report_file.puts(',')
    generate_user_report(last_user_id, users, report_file)
  end

  common_report = <<-JSON
    "totalUsers": #{users_count},
    "uniqueBrowsersCount": #{unique_browser_set.count},
    "totalSessions": #{session_count},
    "allBrowsers": "#{unique_browser_set.to_a.join(",")}"
  JSON

  report_file.puts('},')
  report_file.puts(common_report)
  report_file.puts('}')
  report_file.close
end

print_memory_usage do
  print_time_spent do
    work if ARGV[0]
  end
end
