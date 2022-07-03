require 'rspec-benchmark'
require_relative '../task-2'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'allocation' do
  let(:file_path) { '../data/data1000.txt' }
  it 'allocates under 1.3mb' do
    expect {
      work(file_path)
    }.to perform_allocation(1_300_000).bytes
  end
end

