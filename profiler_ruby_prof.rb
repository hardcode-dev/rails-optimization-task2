# frozen_string_literal: true

require 'ruby-prof'
require_relative './task-2'

RubyProf.measure_mode = RubyProf::MEMORY

results = RubyProf.profile do
  work(ENV['DATA_FILE'] || 'data.txt')
end

RubyProf::MultiPrinter.new(
  results, %i[flat graph graph_html tree call_info stack dot]
).print(path: './reports', profile: 'profile')
