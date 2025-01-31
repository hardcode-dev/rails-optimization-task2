unzip:
	gzip -dk fixtures/data_large.txt.gz

prepare_data:
	make unzip
	head -n 200000 fixtures/data_large.txt > fixtures/data_smal.txt
	head -n 50000 fixtures/data_large.txt > fixtures/data_smal_50000.txt
	head -n 10000 fixtures/data_large.txt > fixtures/data_smal_10000.txt

test:
	ruby tests/reporter_test.rb

perform_test:
	rspec tests/reporter_spec.rb

memeory_prof:
	./bin/report_builder.rb memeory_prof

memeory_prof_to_file:
	./bin/report_builder.rb memeory_prof > reports/memeory_prof_report.txt

stack_prof:
	./bin/report_builder.rb stack_prof

open_stack_prof:
	stackprof reports/stackprof.dump

open_stack_prof_by_method:
	stackprof reports/stackprof.dump --method $(T)

open_stack_prof_by_img:
	stackprof --graphviz reports/stackprof.dump > reports/graphviz.dot
	dot -Tpng reports/graphviz.dot > reports/graphviz.png

ruby_prof:
	./bin/report_builder.rb ruby_prof

open_ruby_prof:
	qcachegrind reports/$(T)

all_reports:
	make memeory_prof
	make stack_prof
	make ruby_prof

run:
	./bin/runner

benchmark:
	./bin/benchmark.rb


