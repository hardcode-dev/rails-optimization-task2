# frozen_string_literal: true

require 'stackprof'
require_relative '../task_2'

profile = StackProf.run(mode: :object, raw: true) do
  work
end

File.write('reports/stackprof.json', JSON.generate(profile))
