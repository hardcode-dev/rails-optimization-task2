# frozen_string_literal: true

require 'ruby-prof'
require_relative '../task-2'

# RubyProf.measure_mode = RubyProf::ALLOCATIONS
RubyProf.measure_mode = RubyProf::MEMORY

result = RubyProf.profile do
  work('tmp/data_80000.txt', disable_gc: false)
end

printer = RubyProf::FlatPrinter.new(result)
printer.print(File.open('tmp/flat-memory.txt', 'w+'))

printer = RubyProf::GraphHtmlPrinter.new(result)
printer.print(File.open('tmp/graph-memory.html', 'w+'))
# `open tmp/graph-memory.html`

printer = RubyProf::CallStackPrinter.new(result)
printer.print(File.open('tmp/callstack-memory.html', 'w+'))
`open tmp/callstack-memory.html`

printer = RubyProf::DotPrinter.new(result)
printer.print(File.open('tmp/graphviz-memory.dot', 'w+'))
# `dot -Tpng tmp/graphviz-memory.dot > tmp/graphviz-memory.png`

printer = RubyProf::CallTreePrinter.new(result)
printer.print(path: 'tmp', profile: 'callgrind')
# brew install qcachegrind
# qcachegrind tmp/callgrind
