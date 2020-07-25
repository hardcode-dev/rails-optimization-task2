require 'rspec-benchmark'
require_relative 'task-2'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

RSpec.describe 'Performance' do
  describe 'work method' do
    it 'generates probable number of objects' do
      expect do
        work(file_path: 'data_samples/data.txt')
      end.to  perform_allocation(74604)
    end
  end
end
