# frozen_string_literal: true
require 'benchmark'
require 'memory_profiler'
require 'stackprof'
require 'ruby-prof'

require_relative '../task-2'

def prepare_to_profile(gc_disable: true, dataset_size: 200_000)
	`head -n #{dataset_size} data_large.txt > data.txt`
	# `cp data_large.txt data.txt`
	GC.disable if gc_disable
end

def memory_profiler_report
	prepare_to_profile(gc_disable: true)
	report = MemoryProfiler.report do
		work(file_name: 'data.txt')
	end
	report.pretty_print(scale_bytes: true)
end

# NOTE: second column represents own memory consumption (without callees)
# stackprof tmp/reports/stackprof_reports/stackprof.dump -m work
# stackprof tmp/reports/stackprof_reports/stackprof.dump -m add_user_stat
#
# show graph
# stackprof --graphviz tmp/reports/stackprof_reports/stackprof.dump > graphviz.dot
# dot -T png graphviz.dot > graphviz.png
def stackprof_profiler_dump
	prepare_to_profile(gc_disable: true)
	StackProf.run(mode: :object, out: 'tmp/reports/stackprof_reports/stackprof.dump', raw: true) do
		work(file_name: 'data.txt')
	end
end

def rubyprof_profiler
	RubyProf.measure_mode = RubyProf::ALLOCATIONS
	prepare_to_profile(gc_disable: true)
	result = RubyProf.profile { work }

	RubyProf::FlatPrinter.new(result).print(STDOUT)
	RubyProf::DotPrinter.new(result).print(File.open('tmp/reports/rubyprof/graphviz.dot', 'w+'))
	# open tmp/reports/rubyprof/graph.html
	RubyProf::GraphHtmlPrinter.new(result).print(File.open('tmp/reports/rubyprof/graph.html', 'w+'))
	# open tmp/reports/rubyprof/callstack.html
	RubyProf::CallStackPrinter.new(result).print(File.open('tmp/reports/rubyprof/callstack.html', 'w+'))
end

def asymptotic_analysis(steps: 7, multiplicator: 2, start_amount: 10000)
	amount = start_amount
	steps.times do
		puts `bundle exec ruby bin/runner.rb #{amount}`
		puts '-------------'
		amount *= multiplicator
	end
end

def run
	prepare_to_profile(gc_disable: false)
	puts "TIME: #{Benchmark.realtime { work } }"
end

# def show_object_space_stat
# 	work
# 	pp ObjectSpace.count_objects
# end
# show_object_space_stat
#

# memory_profiler_report
# rubyprof_profiler
# stackprof_profiler_dump
# asymptotic_analysis
# run
