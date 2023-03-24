require_relative 'task-2'
require 'rspec'
require 'rspec-benchmark'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'perfomance' do
  let(:file) { 'data_part_10000.txt' }

  it 'works linear' do
    sizes = [18,54,162,486,4374,13122,39366]
    expect { |n, _| Work.new.work("data_part_#{n}.txt") }.to perform_linear.in_range(sizes)
  end

  it 'works faster then 10ms' do
    expect { Work.new.work('data_part_1000000.txt')  }.to perform_under(4).sec.warmup(2).times.sample(5).times
  end
end