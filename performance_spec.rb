require 'rspec-benchmark'
require_relative 'task-2.rb'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'Performance' do
  let(:file_name) { '10_000.txt' }

  it 'На обработку выделяется не более 15 MB памяти' do
    expect do
      work(file_name: file_name)
    end.to perform_allocation(15 * 1024 * 1024).memory
  end
end