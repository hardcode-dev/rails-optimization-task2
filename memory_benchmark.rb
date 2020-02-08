require 'rspec-benchmark'
require 'minitest/autorun'
require_relative 'task-2'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'report creation memory allocation' do
  it 'should do' do
    expect {
      work('rspec_sample_data.txt')
    }.to perform_allocation({Array => 15_000, Hash => 20_500, String => 30_000}).bytes
  end
end