clear

echo 'SPECS:'
echo '- - - - - - -'
rspec 'spec/work_spec.rb'
echo '- - - - - - -'
echo

echo 'METRIC:'
echo '- - - - - - -'
ruby 'optimization/check_memory_allocation.rb'
echo '- - - - - - -'
echo

echo 'PROFILER:'
echo '- - - - - - -'
ruby 'optimization/memory-profiler.rb'
ruby 'optimization/rubyprof-profiler.rb'
echo '- - - - - - -'
echo
