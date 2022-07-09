require 'rspec-benchmark'
require_relative 'task-2'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'Performance control' do
  let(:filename) { 'task-2_data.txt' }

  it 'allocates less then 17 MB of memory' do
    expect do
      work(filename)
    end.to perform_allocation(17 * 1024 * 1024).memory
  end
end
