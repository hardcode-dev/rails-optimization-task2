require 'rspec-benchmark'
require_relative 'task-2.rb'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'Performance' do
  let(:file_name) { '10_000.txt' }

  it 'allocates less then 12mb' do
    expect do
      work(file_name: file_name)
    end.to perform_allocation(12 * 1024 * 1024).memory
  end
end