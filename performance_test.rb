require 'rspec-benchmark'
require_relative 'task-2.rb'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

RSpec.describe 'Performance of task-2' do
  let(:filename) { 'data/data_32768.txt' }
  subject { work(filename) }

  it 'consumes not too much memory' do
    expect { subject }.to perform_allocation(70_000_000).bytes
  end
end
