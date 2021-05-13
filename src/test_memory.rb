require 'rspec'
require_relative 'report'

context 'Memory test' do
  let(:data) { 'data_500000.txt' }

  it 'consumes less then 20 MB' do
    memory = `ps -o rss= -p #{Process.pid}`.to_i / 1024
    work(data)
    memory_after = `ps -o rss= -p #{Process.pid}`.to_i / 1024
    expect(memory_after - memory).to be <= 20
  end
end
