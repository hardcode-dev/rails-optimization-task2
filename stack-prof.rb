require 'json'
require 'stackprof'
require_relative 'task-2.rb'

StackProf.run(mode: :object, out: 'reports/stackprof.dump', raw: true) do
  work('data_large.txt')
end