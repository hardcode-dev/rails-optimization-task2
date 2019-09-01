# frozen_string_literal: true

require 'stackprof'
require_relative '../task-2.rb'

report = Report.new('data/data_512x.txt')

StackProf.run(mode: :object, out: 'stackprof_reports/stackprof.dump', raw: true) do
  report.work
end
