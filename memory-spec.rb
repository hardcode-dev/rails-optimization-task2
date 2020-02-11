require 'rspec-benchmark'
require_relative 'task-2.rb'

RSpec.describe "Memory testing" do
  it 'performs with rss under 70 Mb' do
    memory_before = `ps -o rss= -p #{Process.pid}`.to_i / 1024

    puts "RSS size before programm execution: #{memory_before} Mb."
    puts "Start program execution."

    work('data_small.txt')

    memory_after = `ps -o rss= -p #{Process.pid}`.to_i / 1024
    puts "RSS size after programm execution: #{memory_before} Mb."

    memory_diff = memory_after - memory_before
    puts "Memory increase equals #{memory_diff} Mb."

    expect(memory_after - memory_before).to be <= 2
  end
end
