# frozen_string_literal: true

class User
  attr_reader :attributes
  attr_accessor :sessions_count, :total_time, :longest_session, :browsers, :used_ie, :used_only_chrome, :dates

  def initialize(attributes:)
    @attributes = attributes
    set_default_values
  end

  def full_name
    @full_name ||= "#{attributes[:first_name]} #{attributes[:last_name]}"
  end

  private

  def set_default_values
    @sessions_count = 0
    @total_time = 0
    @longest_session = 0
    @browsers = []
    @used_ie = false
    @used_only_chrome = true
    @dates = []
  end

end
