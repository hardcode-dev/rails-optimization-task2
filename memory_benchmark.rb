# frozen_string_literal: true

require 'rspec-benchmark'
require 'minitest/autorun'
require_relative 'task-2'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'report creation memory allocation' do
  it 'should do' do
    expect do
      work('rspec_sample_data.txt')
    end.to perform_allocation(Array => 9_300, Hash => 13_300, String => 35_500).bytes
  end
end
