class User
  attr_reader :attributes, :sessions

  def initialize(attributes:)
    @attributes = attributes
    @sessions = attributes['sessions']
  end
end
