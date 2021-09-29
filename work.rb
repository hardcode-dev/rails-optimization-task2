require 'json'
require 'pry'
require 'date'

require_relative 'user.rb';

def parse_session(fields)
  {
    'user_id' => fields[1],
    'session_id' => fields[2],
    'browser' => fields[3],
    'time' => fields[4],
    'date' => fields[5],
  }
end

def work(filename:, disable_gc: false)
  GC.disable if disable_gc

  totalUsers = 0
  totalSessions = 0
  browsers = []

  result_file = File.open('result.json', 'w')

  result_file.write("\{\"usersStats\":\{")

  current_user = nil;
  cols = [];
  File.foreach(filename).each do |line|
    cols.clear
    line.chomp.split(',') { |val| cols << val }

    if cols[0] == 'user'
      result_file.write(current_user.to_s + ',') if current_user
      current_user = User.new(cols)
      totalUsers += 1
    else
      session = parse_session(cols)
      current_user.sessions << session
      totalSessions += 1
      browsers << session['browser'].upcase
    end
  end
  result_file.write(current_user.to_s)
  browsers.uniq!

  result_file.write("\},")
  result_file.write("\"totalUsers\":#{totalUsers},\"uniqueBrowsersCount\":#{browsers.count},\"totalSessions\":#{totalSessions},\"allBrowsers\":\"#{browsers.sort.join(',')}\"\}")
  result_file.close
end
