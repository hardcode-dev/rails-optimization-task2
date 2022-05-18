# frozen_string_literal: true

require './helpers/row/user'
require './helpers/row/session'

class User
  attr_reader :attributes, :sessions

  def initialize(attributes, sessions)
    @attributes = attributes
    @sessions   = sessions
  end

  def full_name
    "#{attributes[Row::User::FIRST_NAME]} #{attributes[Row::User::LAST_NAME]}"
  end

  def stats
    {
      'sessionsCount'    => sessions.count,
      'totalTime'        => "#{sessions_time.sum} min.",
      'longestSession'   => "#{sessions_time.max} min.",
      'browsers'         => browsers.join(",\s"),
      'usedIE'           => browsers.any? { |b| b.start_with?('INTERNET EXPLORER') },
      'alwaysUsedChrome' => browsers.all? { |b| b.start_with?('CHROME') },
      'dates'            => sessions.map { |s| s[Row::Session::DATE].strip! }.sort.reverse
    }
  end

  private

  def browsers
    @browsers ||= sessions.map { |s| s[Row::Session::BROWSER].upcase }.sort
  end

  def sessions_time
    @sessions_time ||= sessions.map { |s| s[Row::Session::TIME].to_i }
  end
end
