require 'rspec/core/rake_task'
require 'rake/testtask'
require 'benchmark'
# require_relative 'benchmark/ruby-prof'

task default: %i[test benchmark_spec processing_time memory_profiler dummy_benchmark]

task :benchmark_spec do
  RSpec::Core::RakeTask.new.run_task(false)
end

task :test do
  Rake::TestTask.new do |t|
    t.test_files = ['test/user_test.rb']
  end
end

task :ruby_prof do
  ruby 'profile/ruby-prof.rb'
end

task :stackprof do
  ruby 'profile/stackprof.rb'
  system 'stackprof profile/reports/stackprof.dump'
end

task :processing_time do
  ruby 'profile/processing_time.rb'
end

task :memory_profiler do
  ruby 'profile/memory_profiler.rb'
end

task :dummy_benchmark do
  ruby 'profile/dummy_benchmark.rb'
end
