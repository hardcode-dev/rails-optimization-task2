guard :minitest do
  watch('test/task-2_test.rb')
  watch('task-2.rb') { |_m| 'test/task-2_test.rb' }
end

guard :shell do
  watch('task-2.rb') do |_m|
    system('DATA_FILE=data_large.txt VERBOSE=true ruby work.rb')
    system('ruby benchmark/memory_profiler_bench.rb | head -n 20')
  end
end

# guard :rspec, cmd: 'rspec -f doc' do
#   watch('spec/task-1_spec.rb')
#   watch('task-1.rb') { |_m| 'spec/task-1_spec.rb' }
# end
