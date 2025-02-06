.PHONY: all_reports
all_reports:
	ruby benchmark.rb
	ruby rubyprof_allocation.rb
	ruby rubyprof_memory.rb
	ruby memory_profiler.rb




