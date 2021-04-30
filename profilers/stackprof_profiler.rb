require 'json'
require 'stackprof'
require_relative '../task-2'

profile = StackProf.run(model: :object, raw: true) do
  ReportGenerate.new.work(ENV['FILENAME'] || 'data.txt')
end

File.write('reports/stackprof.json', JSON.generate(profile))