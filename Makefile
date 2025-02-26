all_reports:
	ruby ruby-prof-allocations.rb
	ruby ruby-prof-memory.rb
	ruby memory-profiler.rb
	ruby benchmark.rb
