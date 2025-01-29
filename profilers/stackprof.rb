require 'stackprof'
require 'json'
require_relative '../task-2.rb'

profile = StackProf.run(mode: :object, raw: true) do
  work(file_path: 'test_data/data5000.txt')
end

File.write('tmp/stackprof-speedscore.json', JSON.generate(profile))
