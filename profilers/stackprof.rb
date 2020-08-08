# frozen_string_literal: true

require 'stackprof'
require_relative '../task-2.rb'

`head -n 12500 data_large.txt > data_large12500.txt`

StackProf.run(mode: :object, out: 'reports/stackprof.dump', interval: 1000) do
  work(filename: 'data_large12500.txt', gc: false)
end

`rm data_large12500.txt`
