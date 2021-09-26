# frozen_string_literal: true

require 'forwardable'

class User
  attr_reader :attributes
  attr_accessor :sessions

  # It will be great to use ObjectSpace.each_object(User) in this example instead of defining class attribute,
  # but it can lead to unpredictable results if GC decides to delete User instances.
  @all = []

  class << self
    extend Forwardable

    attr_reader :all

    def_delegators :all, :sum, :size, :last

    def create(attributes:)
      @all << new(attributes: attributes)
    end
  end

  def initialize(attributes:)
    @attributes = attributes
    @sessions = []
  end

  def full_name
    @full_name ||= "#{attributes[:first_name]} #{attributes[:last_name]}"
  end

end
