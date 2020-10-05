# frozen_string_literal: true

require 'json'
require 'pry'
require 'date'
require 'set'

class Summary
  def initialize
    @users = 0
    @sessions = 0
    @browsers = Set.new
  end

  def on_user
    @users += 1
  end

  def on_session(browser)
    @sessions += 1
    @browsers << browser
  end

  def dump(io)
    io << '"totalUsers":'<< @users << ','
    io << '"uniqueBrowsersCount":' << @browsers.size << ','
    io << '"totalSessions":' << @sessions << ','
    io << '"allBrowsers":"' << @browsers.sort.join(',') << '"'
  end
end

class UserStats
  attr_writer :full_name

  def initialize
    reset(true)
  end

  def reset(first_user)
    @first = first_user

    @full_name = nil
    @sessions = 0
    @total_time = 0
    @longest_session = 0
    @browsers = []
    @used_ie = false
    @always_used_chrome = true
    @dates = []
  end

  def on_session(browser, time, date)
    @sessions += 1
    @total_time += time
    @longest_session = time if time > @longest_session
    @browsers << browser
    @used_ie ||= browser.start_with?('INTERNET EXPLORER')
    @always_used_chrome &&= browser.start_with?('CHROME')
    @dates << date
  end

  def dump(io)
    @dates.sort! { |a, b| b <=> a }

    io << ',' unless @first

    io << '"' << @full_name << '":{"sessionsCount":' << @sessions << ','
    io << '"totalTime":"' << @total_time << ' min.",'
    io << '"longestSession":"' << @longest_session << ' min.",'
    io << '"browsers":"' << @browsers.sort.join(', ') << '",'
    io << '"usedIE":' << @used_ie << ','
    io << '"alwaysUsedChrome":' << @always_used_chrome << ','
    io << '"dates":' << @dates.to_json << '}'

    reset(false)
  end
end

def work(src:, dest:)
  users = []
  sessions = []

  out = File.open(dest, 'w')

  out << '{"usersStats":{'

  summary = Summary.new
  last_user_stats = nil

  File.open(src).each_line do |line|
    line.rstrip!

    column_index = 0

    type = nil
    first_name = nil
    browser = nil
    time = nil
    date = nil

    line.split(',') do |column|
      case type
      when 'user'
        case column_index
        when 1
          summary.on_user

          if last_user_stats
            last_user_stats.dump(out)
          else
            last_user_stats = UserStats.new
          end
        when 2 then first_name = column
        when 3 then last_user_stats.full_name = first_name + ' ' + column
        end

      when 'session'
        case column_index
        when 3 then browser = column
        when 4 then time = column.to_i
        when 5 then
          browser.upcase!

          last_user_stats.on_session(browser, time, column)
          summary.on_session(browser)
        end
      else
        type = column
      end

      column_index += 1
    end
  end

  last_user_stats.dump(out) # dump the last user
  out << '},' # close "usersStats" object
  summary.dump(out) # dump report summary
  out << '}' # close top-level object

  out.close
end
