.PHONY: test

samples:
	ruby benchmark/data_samples.rb
test:
	ruby test/task_2_test.rb
