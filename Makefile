install:
	bundle install

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

profile_memory_profiler:
	ruby reports/memory-profiler/profile.rb

# ========================= #
# Stackprof
# ========================= #

profile_stackprof:
	ruby reports/stackprof/profile.rb

show_stackprof:
	stackprof reports/stackprof/report.dump

# перед запуском выполните make install_imgcat
show_stackprof_graph:
	stackprof --graphviz reports/stackprof/report.dump > reports/stackprof/graphviz.dot
	dot -Tpng reports/stackprof/graphviz.dot > reports/stackprof/graphviz.png
	imgcat reports/stackprof/graphviz.png

install_imgcat:
	brew install eddieantonio/eddieantonio/imgcat

# ========================= #
# Запуск valgrind профилировщика:
# 1. Установите xquartz:
# make install_xquartz
# 2. Соберите докер образ:
# make valgrind_build
# 3. Запустите профилировщик:
# make valgrind_profile
# 4. Запустите socat:
# make run_socat
# 5. Запустите GUI valgrind для просмотра отчета профилировщика:
# make valgrind_visualize
# ========================= #

install_xquartz:
	brew install xquartz --cask

valgrind_build:
	export USER=$(id -un)
	reports/docker-valgrind-massif/docker-build.sh

run_socat:
	socat TCP-LISTEN:6000,reuseaddr,fork UNIX-CLIENT:\"$DISPLAY\"

valgrind_profile:
	reports/docker-valgrind-massif/profile.sh

valgrind_visualize:
	reports/docker-valgrind-massif/visualize.sh