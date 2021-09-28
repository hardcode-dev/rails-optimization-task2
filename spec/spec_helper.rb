require 'rspec-benchmark'
require_relative '../task-2'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end
