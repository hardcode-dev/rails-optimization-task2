require 'rspec-benchmark'
require_relative './task-2.rb'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'Memory perfomance' do
  context 'with 5000 strings' do
    it 'allocate 5Mb memory' do
      expect { work(file_path: 'test_data/data5000.txt') }.to perform_allocation(10 * 1024 * 1024).bytes
    end
  end
end
