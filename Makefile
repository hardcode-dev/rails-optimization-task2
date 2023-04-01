generate_data_files:
	mkdir data
	gzcat data_large.txt.gz > data/data_large.txt
	head -n 1000 data/data_large.txt > data/data_1000.txt
	head -n 10000 data/data_large.txt > data/data_10_000.txt
	head -n 32500 data/data_large.txt > data/data_32_500.txt
	head -n 100000 data/data_large.txt > data/data_100_000.txt
	head -n 1000000 data/data_large.txt > data/data_1_000_000.txt

remove_data_files:
	rm data/data_large.txt
	rm data/data_1000.txt
	rm data/data_10_000.txt
	rm data/data_32_500.txt
	rm data/data_100_000.txt
	rm data/data_1_000_000.txt

test:
	rspec specs

work:
	ruby work.rb

work_with_progressbar:
	ruby work_with_progressbar.rb