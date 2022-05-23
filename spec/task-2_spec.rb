# frozen_string_literal: true

require 'spec_helper'

require_relative '../task-2.rb'

RSpec.describe '#work' do

  describe 'used memory' do
    let(:expected_metric_mb) { 17.75 }
    let(:bytes) { expected_metric_mb * 1048576 }

    it 'corresponds to the limit while Ruby code execution' do
      expect {
        work('./benchmark/support/data_16k.txt', disable_gc: false)
      }.to perform_allocation(bytes).bytes.warmup(0.2)
    end
  end

  describe 'ips' do
    it 'corresponds to the threshold value of iterations per second ' do
      expect { work('./benchmark/support/data_16k.txt') }.to perform_at_least(13).ips.within(0.5)
    end
  end
end
