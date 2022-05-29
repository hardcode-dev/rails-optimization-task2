require 'rspec-benchmark'
require 'rspec'
require 'bytesize'

require_relative 'parser'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

RSpec.describe 'parser' do
  describe 'memory usage' do
    let(:expected_memory_usage) { ByteSize.mb(40).to_bytes }

    it 'uses less than expected memory usage' do
      expect {
        Parser.new.work(file_name: 'data20000.txt')
      }.to perform_allocation(expected_memory_usage).bytes
    end
  end
end
