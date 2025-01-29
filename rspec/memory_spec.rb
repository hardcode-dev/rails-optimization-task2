require 'rspec-benchmark'
require_relative '../task-2.rb'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'Performance' do
  describe 'work' do
    let(:filename) { 'rspec/test_data/data1000.txt' }

    it 'works under 30 MB' do
      expect {
        work(filename)
      }.to perform_allocation(30_000_000).bytes
    end
  end
end
