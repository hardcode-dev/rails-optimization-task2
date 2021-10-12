# frozen_string_literal: true

require 'stackprof'
require_relative './task-2'

profile = StackProf.run(mode: :object, out: 'reports/stackprof.dump', raw: true, interval: 1) do
  work(ENV['DATA_FILE'] || 'data.txt')
end

# StackProf::Report.new(profile).print_text
# StackProf::Report.new(profile).print_graphviz
