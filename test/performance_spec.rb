# frozen_string_literal: true

require 'rspec-benchmark'
require_relative '../task-2.rb'

RSpec.configure { |config| config.include RSpec::Benchmark::Matchers }

describe 'Performance' do
  describe 'large data' do
    let(:file) { 'data_large.txt' }

    it 'allocates 70mb' do
      work(file)
      memory = `ps -o rss= -p #{Process.pid}`.to_i / 1024
      expect(memory).to be < 70
    end
  end
end
