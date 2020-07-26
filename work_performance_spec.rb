require 'rspec-benchmark'
require_relative 'task-2'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

RSpec.describe 'Performance' do
  describe 'work method' do
    it 'performs under 15 MB memory size ' do
      expect do
        work(file_path: 'data_samples/data1000.txt')
      end.to  perform_allocation(15728640).bytes
    end
  end
end
