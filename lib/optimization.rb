require 'pry'
require 'benchmark'
require_relative 'task-1'
require_relative 'task-2'

module Optimization
  module_function

  class User
    attr_reader :attributes, :sessions

    def initialize(attributes:, sessions:)
      @attributes = attributes
      @sessions = sessions
    end
  end

  def call
    class_name, method_name, args = ARGV
    arguments = args.split(',')

    GC.disable if arguments[0] == 'true'

    time = Benchmark.measure do
      class_name.split('::').reduce(Module, :const_get).send(method_name.to_sym, arguments[1])
    end
    puts "Runtime: #{time.real.round(2)} seconds | MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
  end
end
