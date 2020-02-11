class User
  attr_reader :id, :name, :age
  attr_accessor :sessions, :report

  def initialize(id, name, age)
    @id = id
    @name = name
    @age = age
    @sessions = 0
    @report = Report.new
  end
end
