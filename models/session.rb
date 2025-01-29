# frozen_string_literal: true

class Session
  attr_reader :user_id, :session_id, :browser, :time, :date

  def initialize(user_id, session_id, browser, time, date)
    @user_id = user_id.to_i
    @session_id = session_id.to_i
    @browser = browser.upcase
    @time = time.to_i
    @date = date
  end
end
