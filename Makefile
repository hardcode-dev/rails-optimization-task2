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

profile:
	mkdir -p reports
	mkdir -p reports/tmp
	mkdir -p reports/tmp/stackprof
	mkdir -p reports/tmp/memory-profiler
	mkdir -p reports/tmp/valgrind
	mkdir -p reports/tmp/ruby-prof

	make profile_stackprof
	make valgrind_profile
	make profile_ruby_prof
	make profile_memory_profiler

show_reports:
	make show_stackprof_graph
	make valgrind_visualize
	make show_ruby_prof

mv_reports:
	mv reports/tmp reports/${step}
	mv massif.out.1 reports/valgrind/${step}

# Profilers

profile_ruby_prof:
	ruby profilers/ruby-prof/profile.rb
	ruby profilers/ruby-prof/profile_memory-callgrind.rb

show_ruby_prof:
	open reports/tmp/ruby-prof/callstack.html
	qcachegrind reports/tmp/ruby-prof/callgrind.out.*

profile_memory_profiler:
	ruby profilers/memory-profiler/profile.rb

# ========================= #
# Stackprof
# ========================= #

profile_stackprof:
	ruby profilers/stackprof/profile.rb

show_stackprof:
	stackprof profilers/stackprof/report.dump

# перед запуском выполните make install_imgcat
show_stackprof_graph:
	stackprof --graphviz reports/tmp/stackprof/report.dump > reports/tmp/stackprof/graphviz.dot
	dot -Tpng reports/tmp/stackprof/graphviz.dot > reports/tmp/stackprof/graphviz.png
	imgcat reports/tmp/stackprof/graphviz.png

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
	profilers/docker-valgrind-massif/docker-build.sh

run_socat:
	socat TCP-LISTEN:6000,reuseaddr,fork UNIX-CLIENT:\"$DISPLAY\"

valgrind_profile:
	profilers/docker-valgrind-massif/profile.sh

valgrind_visualize:
	profilers/docker-valgrind-massif/visualize.sh