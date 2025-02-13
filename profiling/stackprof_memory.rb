# frozen_string_literal: true

require 'stackprof'
require 'json'
require_relative '../task-2'

profiling = StackProf.run(mode: :object, raw: true, disable_gc: true) do
  work(file_name: 'data_50_thousands_lines.txt')
end

File.write('profiling/speedscope_50_thousand_v2.json', JSON.generate(profiling))
