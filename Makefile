test:
	ruby test_me.rb

bm:
	ruby benchmarking.rb

prof-flat:
	ruby ruby_prof_flat.rb
#
prof-flat_read:
	cat ruby_prof_reports/flat.txt
#
prof-graph:
	ruby ruby_prof_graph.rb

prof-graph_read:
	open ruby_prof_reports/graph.html

prof-call_stack:
	ruby ruby_prof_call_stack.rb

prof-call_stack_read:
	open ruby_prof_reports/call_stack.html

prof-call_grind:
	ruby ruby_prof_grind.rb

prof-call_grind_read:
	qcachegrind ruby_prof_reports/callgrind.out.${P}

stackprof:
	ruby stackprof.rb

stackprof_read:
	cd stackprof_reports && stackprof stackprof.dump

stackprof_speedscope:
	ruby stackprof_speedscope.rb

.PHONY:	test
