require 'rspec'
require_relative 'task_2'

context 'Memory test' do
  let(:data) { 'data_100000.txt' }

  it 'consumes less then 50 MB' do
    memory = `ps -o rss= -p #{Process.pid}`.to_i / 1024
    work(data)
    memory_after = `ps -o rss= -p #{Process.pid}`.to_i / 1024
    expect(memory_after - memory).to be <= 50
  end
end