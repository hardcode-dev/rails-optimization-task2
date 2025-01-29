require 'json'
require 'stackprof'
require_relative 'task-2.rb'

filename = "data/data_#{ENV['LINES']}.txt"

profile = StackProf.run(mode: :object, raw: true) do
  work(filename)
end

File.write('stackprof_reports/stackprof.json', JSON.generate(profile))

# How to read:
# https://speedscope.app
