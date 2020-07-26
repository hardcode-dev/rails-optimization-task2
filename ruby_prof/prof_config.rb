require 'ruby-prof'
require_relative '../task-2'

RubyProf.measure_mode = RubyProf::WALL_TIME
# RubyProf.measure_mode = RubyProf::ALLOCATIONS
# RubyProf.measure_mode = RubyProf::MEMORY

GC.disable

REPORTS_DIR = 'ruby_prof/reports/'.freeze
DATA_FILE = 'data_samples/data1000.txt'.freeze
