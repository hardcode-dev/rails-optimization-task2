# frozen_string_literal: true

class User
  attr_reader :attributes
  attr_accessor :sessions

  def initialize(attributes:)
    @attributes = attributes
    @sessions = []
  end
end
