# frozen_string_literal: true
require 'set'

require_relative 'user.rb';

def parse_session(fields)
  {
    'browser' => fields[3].upcase,
    'time' => fields[4],
    'date' => fields[5],
  }
end

def work(filename:, disable_gc: false)
  GC.disable if disable_gc

  totalUsers = 0
  totalSessions = 0
  browsers = Set.new

  result_file = File.open('result.json', 'w')

  result_file.write('{"usersStats":{')

  current_user = nil;
  cols = [];
  File.foreach(filename) do |line|
    cols.clear
    line.chop.split(',') { |val| cols << val }

    if cols[0] == 'user'
      result_file.write(current_user.to_s + ',') if current_user
      current_user = User.new(cols)
      totalUsers += 1
    else
      session = parse_session(cols)
      current_user.sessions << session
      totalSessions += 1
      browsers.add session['browser']
    end
  end
  result_file.write(current_user.to_s)

  result_file.write('},')
  result_file.write("\"totalUsers\":#{totalUsers},\"uniqueBrowsersCount\":#{browsers.count},\"totalSessions\":#{totalSessions},\"allBrowsers\":\"#{browsers.sort.join(',')}\"\}")
  result_file.close
end
