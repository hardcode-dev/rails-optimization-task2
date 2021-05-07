require_relative 'spec_helper'
require_relative '../task-2'

describe 'allocation' do
  let(:data) { 'data500.txt' }
  let(:budget) { 600000 }

  context 'allocates less than' do
    it do
      expect { work(file: data, disable_gc: true) }.to perform_allocation(budget).bytes
    end
  end
end
