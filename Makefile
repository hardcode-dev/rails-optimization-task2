generate_data_files:
	gunzip data_large.txt
	head -n 1000 data_large.txt > data_1000.txt
	head -n 10000 data_large.txt > data_10_000.txt
	head -n 100000 data_large.txt > data_100_000.txt
	head -n 1000000 data_large.txt > data_1_000_000.txt

remove_data_files:
	rm data_large.txt
	rm data_1000.txt
	rm data_10_000.txt
	rm data_100_000.txt
	rm data_1_000_000.txt
